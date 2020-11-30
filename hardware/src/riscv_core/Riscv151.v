module Riscv151 #(
    parameter SYSTEM_CLOCK_FREQ = 125_000_000,
    parameter CPU_CLOCK_FREQ = 50_000_000
)(
    input clk,
    input rst,

    // Ports for UART that go off-chip to UART level shifter
    input FPGA_SERIAL_RX,
    output FPGA_SERIAL_TX,

    input [2:0] buttons_raw,

    input [1:0] switches,

    input [5:0] leds
);

    // Instantiate your memories here
    // You should tie the ena, enb inputs of your memories to 1'b1
    // They are just like power switches for your block RAMs
    wire [31:0] if_pc;
    wire [31:0] instruction;

    wire [3:0] wr_mask;
    wire [31:0] ma_pc;
    wire data_wren;
    wire [31:0] data_addr;
    wire [31:0] data_rd_data;
    wire [31:0] data_wr_data;

    wire stall;

    // Construct your datapath, add as many modules as you want
    CPU_pipelined_module cpu (
        .clk(clk),
        .rst(rst),
        .pc(if_pc),
        .data_pc(ma_pc),
        .imem_data(instruction),
        .data_wr_en(data_wren),
        .data_addr(data_addr),
        .data_wr_data(data_wr_data),
        .data_wr_mask(wr_mask),
        .data_rd_data(data_rd_data),// data read in from mem
        .stalling(stall)
    );

    wire [31:0] bios_outa;
    wire [31:0] bios_outb;
    wire [31:0] dmem_out;
    wire [31:0] imem_outa;
    wire [31:0] imem_outb;
    wire dmem_wren;
    wire imem_wrena;

    wire uart_dout_valid;
    wire uart_din_ready;
    wire [7:0] uart_dout;
    wire uart_dout_ready;
    wire uart_din_valid;

    wire [31:0] instr_count;
    wire [31:0] cycle_count;
    wire counter_reset;

    wire buttons_empty;
    wire buttons_rd_en;
    wire [3:0] buttons_data;

    mem_controller mem_ctrl (
        .clk(clk),
        .if_pc(if_pc),
        .instruction(instruction),

        .ma_pc(ma_pc),
        .ma_addr(data_addr),
        .ma_data(data_wr_data),
        .mem_wren(data_wren),
        .data_rd_data(data_rd_data),

        .bios_outa(bios_outa),
        .bios_outb(bios_outb),

        .dmem_out(dmem_out),
        .dmem_wren(dmem_wren),

        .imem_wrena(imem_wrena),
        .imem_outb(imem_outb),

        .uart_dout_valid(uart_dout_valid),
        .uart_din_ready(uart_din_ready),
        .uart_dout(uart_dout),
        .uart_din_valid(uart_din_valid),
        .uart_dout_ready(uart_dout_ready),

        .count_cycles(cycle_count),
        .count_instructions(instr_count),
        .counter_rst(counter_reset),

        .buttons_fifo_empty(buttons_empty),
        .buttons_fifo_rd_en(buttons_rd_en),
        .buttons_fifo_data(buttons_data),

        .switches(switches),

        .leds(leds)
    );

    bios_mem bios (
        .clka(clk),
        .ena(1'b1),
        .addra(data_addr[13:2]),
        .douta(bios_outa),
        .clkb(clk),
        .enb(1'b1),
        .addrb(if_pc[13:2]),// parsed alu out
        .doutb(bios_outb)
    );

    wire [13:0] word_aligned_data_addr;
    assign word_aligned_data_addr = data_addr[15:2];

    dmem_blk_ram dmem (
        .clka(clk),
        .ena(1'b1),
        .wea(dmem_wren ? wr_mask : 4'd0),
        .addra(word_aligned_data_addr),
        .dina(data_wr_data),
        .douta(dmem_out)
    );

    imem_blk_ram imem (
        .clka(clk),
        .ena(1'b1),
        .wea(imem_wrena ? wr_mask : 4'd0),
        .addra(word_aligned_data_addr),
        .dina(data_wr_data),
        .clkb(clk),
        .doutb(imem_outb),
        .addrb(if_pc[15:2])
    );

    reg [7:0] uart_din;
    always @(posedge clk) begin
        uart_din <= rst ? 0 : data_wr_data[7:0];
    end

    // On-chip UART
    uart #(
        .CLOCK_FREQ(CPU_CLOCK_FREQ)
    ) on_chip_uart (
        .clk(clk),
        .reset(rst),
        .data_in(uart_din),

        .data_in_valid(uart_din_valid),
        .data_in_ready(uart_din_ready),
        .serial_out(FPGA_SERIAL_TX),

        .data_out(uart_dout),
        .data_out_valid(uart_dout_valid),
        .data_out_ready(uart_dout_ready),
        .serial_in(FPGA_SERIAL_RX)
    );

    // On chip icounter
    instruction_counter instr_ctr(
        .clk(clk),
        .rst(rst),
        .stall_detected(stall),
        .reset_counters(counter_reset),
    .instr_counter(instr_count),
    .cycle_counter(cycle_count)
    );

    wire buttons_full;

    // On chip button fifo
    fifo #(
        .data_width(3)
    ) buttons_fifo (
        .clk(clk),
        .rst(rst),

        .wr_en(!buttons_full && (|buttons_raw)),
        .full(buttons_full),
        .din(buttons_raw),

        .rd_en(buttons_rd_en),
        .dout(buttons_data),
        .empty(buttons_empty)
    );

    // On chip tonegen

    // On chip i2s_controller

endmodule
