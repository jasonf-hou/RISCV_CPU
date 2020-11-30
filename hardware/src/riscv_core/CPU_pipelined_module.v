module CPU_pipelined_module (
    // Global wires
    input clk, // System clock
    input rst, // System reset
    
    output stalling,

    // Instruction fetching
    output [31:0] pc, // Current instruction address
    input [31:0] imem_data, // Current instruction

    // Data read/writing
    output [31:0] data_pc, // Pipelined PC at time of memory write/read
    output data_wr_en, // Asserted when we would like to write to memory
    output [31:0] data_addr, // Address we would like to read or write from, word aligned
    output [3:0] data_wr_mask,
    output [31:0] data_wr_data, // Data that we would like to write to memory
    input [31:0] data_rd_data // Data that we read from memory.
);
    // IF: Non-pipeline control signals
    wire [31:0] new_pc;
    wire pc_override;

    if_module ifetch (
        .clk(clk),
        .rst(rst),
	.new_pc(new_pc),
	.pc_override(pc_override),
	.pc(pc)
    );

    // EX: Pipeline outputs
    wire [31:0] alu_out;
    wire [31:0] mem_wr_data;
    wire mem_wr_enable;
    wire mem_rd_enable;
    wire rf_wb_later;
    wire [2:0] mem_mask_sel;
    wire [4:0] rd;

    // EX: Pipeline inputs
    wire rf_wb_enable;
    wire [4:0] rf_wb_rd;
    wire [31:0] rf_wb_data;

    // EX: Forwarding output
    wire [4:0] rs1;
    wire [4:0] rs2;

    // EX: Forwarding input
    wire [31:0] fw_val;
    wire rs1_fw_enable;
    wire rs2_fw_enable;
    
    wire dex_stall;
    assign stalling = dex_stall;
    dex_module dex (
        .clk(clk),
        .rst(rst),
	
	   .stall(dex_stall),
	.pc(pc),
	.instruction(imem_data),
	
	.rf_wb_enable(rf_wb_enable),
	.rf_wb_rd(rf_wb_rd),
	.rf_wb_data(rf_wb_data),
	
	.alu_out(alu_out),
	.rd(rd),
	.pc_pl(data_pc),
	.mem_wr_data(mem_wr_data),
	.mem_write_enable(mem_wr_enable),
	.mem_read_enable(mem_rd_enable),
	.mem_mask_sel(mem_mask_sel),
	.rf_wb_later(rf_wb_later),
	.new_pc(new_pc),
	.pc_override(pc_override),
	.rs1(rs1),
	.rs2(rs2),
	.rs1_fw_enable(rs1_fw_enable),
	.rs2_fw_enable(rs2_fw_enable),
	.fw_val(fw_val)
    );

    wire rd_en_pl;
    ma_module ma (
        .clk(clk),
        .rst(rst),
        
        .alu_out(alu_out),
        .rf_wb_later(rf_wb_later),
        .rd(rd),
        .mem_wr_data(mem_wr_data),
	
        .mem_wr_en(mem_wr_enable),
        .mem_rd_en(mem_rd_enable),
        .mem_mask_sel(mem_mask_sel),
        .mem_data_rd(data_rd_data),
        
        .mem_wr_en_out(data_wr_en),
        .mem_wr_data_out(data_wr_data),
	
        .wb_data_pl(rf_wb_data),
        .wb_en_pl(rf_wb_enable),
        .wb_rd_pl(rf_wb_rd),
        .mem_addr(data_addr),
        .mem_wr_mask(data_wr_mask)
    );

    hazard_control haz_ctrl (
	.ex_rs1(rs1),
	.ex_rs2(rs2),
	.ma_rd(rf_wb_rd),
	.ma_rf_wb_en(rf_wb_enable),
	.ma_rd_val(rf_wb_data),
	.forward_value_ex(fw_val),
	.ex_rs1_fwd(rs1_fw_enable), .ex_rs2_fwd(rs2_fw_enable)
    );


endmodule
