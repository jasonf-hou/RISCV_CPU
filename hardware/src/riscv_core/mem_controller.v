// This controller should handle outputs for store instructions including the we mask (which instructs the RAM
// which and how many bits to write to memory)
module mem_controller(
    input clk,
    // IFD support
    input [31:0] if_pc, // PC of the current instruction to be fetch
    output reg [31:0] instruction, // Instruction to fetch

    // MA support
    input [31:0] ma_pc, // PC at the time of memory fetch
    input [31:0] ma_addr, // Address to fetch from, word aligned
    input [31:0] ma_data, // Data to write to memory-mapped devices; DO NOT use for block RAM
    input mem_wren, // Asserted when the CPU would like to write to memory
    output reg [31:0] data_rd_data, // Word fetched from memory

    // BIOS interface
    input [31:0] bios_outa, // Output of the BIOS memory (MA support)
    input [31:0] bios_outb, // Output of the BIOS memory (IFD support)
    
    // DMEM interface
    input [31:0] dmem_out, // Output of the DMEM memory
    output reg dmem_wren, // Asserted when we would like to write to DMEM
    
    // IMEM interface
    output reg imem_wrena, // Asserted when we would like to write to IMEM, port A (MA support)
    input [31:0] imem_outb, // Output of the IMEM, port B (IFD support)
    
    // UART interface
    input uart_dout_valid, // Asserted when UART has valid data
    input uart_din_ready, // Asserted when UART is ready to transmit data
    input [7:0] uart_dout, // Data received over UART
    output reg uart_din_valid, // Asserted when we would like to xmit a byte over UART
    output reg uart_dout_ready, // Asserted when we would like to read a byte over UART
    
    // Counter interface
    input [31:0] count_cycles,
    input [31:0] count_instructions,
    output reg counter_rst,
    
    // GPIO FIFO Switch interface
    input buttons_fifo_empty,
    output reg buttons_fifo_rd_en,
    input [2:0] buttons_fifo_data,
    
    // Switches interface
    input [1:0] switches,
    
    // GPIO LED interface
    output reg [5:0] leds
);

    reg [31:0] read_addr;
    
    always @(posedge clk) begin
        read_addr <= ma_addr;
    end

    wire [3:0] mem_partition = ma_addr[31:28];
    wire [3:0] read_partition = read_addr[31:28];
    wire [3:0] pc_prefix = if_pc[31:28];
    
    always @(*) begin
        instruction = 0;
        dmem_wren = 0;
        imem_wrena = 0;
        data_rd_data = 0;
        uart_din_valid = 0;
        uart_dout_ready = 0;
        counter_rst = 0;
        buttons_fifo_rd_en = 0;
        // IFD support
        if (pc_prefix == 4'b0001) begin
            instruction = imem_outb;
        end else if (pc_prefix == 4'b0100) begin
            instruction = bios_outb;    
        end
          
        // MA write support
        if (mem_wren) begin
            if (mem_partition[3:2]==2'b0 && mem_partition[0]==1) begin
                dmem_wren = 1;
            end
            if (mem_partition[3:1]==3'b001 && ma_pc[30]==1) begin
                imem_wrena = 1;
            end
            if (mem_partition == 4'b1000) begin
                // IO write functions.
                if (ma_addr == 32'h80000008) begin
                    uart_din_valid = 1; 
                end
                else if (ma_addr == 32'h80000018) counter_rst = 1'b1;
                else if (ma_addr == 32'h80000030) leds = ma_data[5:0];
            end
        end
        // MA read support
        // IO read control signaling
        if (read_addr == 32'h80000004) begin
            uart_dout_ready = 1;
        end else if (read_addr == 32'h80000024) begin
            buttons_fifo_rd_en = 1;
        end
    
        if (read_partition[3:2]==2'b0 && read_partition[0]==1) begin
            data_rd_data = dmem_out;
        end else if (read_partition == 4'b0100) begin
            data_rd_data = bios_outa;
        end else if (read_partition == 4'b1000) begin
            // IO read functions.
            if (read_addr == 32'h80000000) begin
                data_rd_data = { uart_dout_valid, uart_din_ready };
            end else if (read_addr == 32'h80000004) begin
                data_rd_data = uart_dout;
            end 
            else if (read_addr == 32'h80000010) data_rd_data = count_cycles;
            else if (read_addr == 32'h80000014) data_rd_data = count_instructions;
            else if (read_addr == 32'h80000020) data_rd_data = buttons_fifo_empty;
            else if (read_addr == 32'h80000024) data_rd_data = buttons_fifo_data;
            else if (read_addr == 32'h80000028) data_rd_data = switches;
        end
    end
endmodule
