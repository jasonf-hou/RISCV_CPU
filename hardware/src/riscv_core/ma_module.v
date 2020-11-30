module ma_module(
    input clk, // System clock
    input rst, // System reset

    input [31:0] alu_out, // Output of the ALU from EX stage
    input rf_wb_later,
    input [4:0] rd,
    input [31:0] mem_wr_data, // Data we want to write to memory from EX stage

    input mem_wr_en, // Asserted when we want to write to memory
    input mem_rd_en, // Asserted when we want to read from memory
    input [2:0] mem_mask_sel,
    input [31:0] mem_data_rd,
    output mem_wr_en_out,
    output [31:0] mem_wr_data_out,
    output [31:0] mem_addr, // Address we want to R/W from/to
    output [3:0] mem_wr_mask,
    
    output [31:0] wb_data_pl, // Data to be written back into register, also used as a forwarding path for EX; naturally pipelined
    output reg wb_en_pl,
    output reg [4:0] wb_rd_pl
);
    reg mem_rd_en_pipe; // Used to keep state of memory read for selecting writeback output
    reg [31:0] alu_out_pipe; // Used to internally delay the aluout for non-mem instructions
    wire [31:0] mem_data_rd_masked;
    reg [2:0] mem_mask_sel_pipe;
    reg [1:0] mem_byte_offset_pipe;
    
    wire invalid_addr;
    
    assign mem_wr_en_out = !invalid_addr && mem_wr_en;
    
    always @(posedge clk) begin
	if (rst) begin
            alu_out_pipe <= 0;
            mem_rd_en_pipe <= 0;
            mem_mask_sel_pipe <= 0;
            mem_byte_offset_pipe <= 0;
	    wb_en_pl <= 0;
	    wb_rd_pl <= 0;
	end else begin
	    alu_out_pipe <= alu_out;
	    mem_rd_en_pipe <= mem_rd_en;
	    mem_mask_sel_pipe <= mem_mask_sel;
	    mem_byte_offset_pipe <= alu_out[1:0];
	    wb_en_pl <= rf_wb_later;
	    wb_rd_pl <= rd;
	end
    end
    
    mem_r_decoder mem_read_decoder(
        .fnc(mem_mask_sel_pipe),
        .byte_offset(mem_byte_offset_pipe),
        .raw_data(mem_data_rd),
        .data_out(mem_data_rd_masked)
    );
    
    mem_wr_decoder mem_write_decoder (
        .fnc(mem_mask_sel),
        .addr(alu_out),
        .wr_data(mem_wr_data),
        .wr_dout(mem_wr_data_out),
        .wr_mask(mem_wr_mask),
        .invalid_addr(invalid_addr)
    );

    assign wb_data_pl = mem_rd_en_pipe ? mem_data_rd_masked: alu_out_pipe;
    assign mem_addr = alu_out & 32'hfffffffc;

endmodule
