module dex_module(
    // Global wires
    input clk, // Global clock
    input rst, // Global reset

    // Pipeline inputs (IF)
    input [31:0] pc,
    input [31:0] instruction,

    // Pipeline inputs (MA)
    input rf_wb_enable,
    input [4:0] rf_wb_rd,
    input [31:0] rf_wb_data,

    // Pipeline outputs
    output [31:0] alu_out,
    output [4:0] rd,

    output reg [31:0] pc_pl,
    output [31:0] mem_wr_data,
    output mem_write_enable,
    output mem_read_enable,
    output [2:0] mem_mask_sel,
    output rf_wb_later,

    // Non-pipeline outputs
    output reg [31:0] new_pc,
    output pc_override,
    output reg stall,
    
    // Forwarding paths
    output [4:0] rs1,
    output [4:0] rs2,
    input rs1_fw_enable,
    input rs2_fw_enable,
    input [31:0] fw_val
);
    always @(posedge clk) begin
        if (rst) begin
            pc_pl <= 32'h40000000;
        end else begin
            pc_pl <= pc;
        end
    end

    wire [31:0] rs1_data_fw;
    wire [31:0] rs2_data_fw;

    wire [31:0] rs1_data;
    wire [31:0] rs2_data;

    assign rs1_data_fw = rs1_fw_enable ? fw_val : rs1_data;
    assign rs2_data_fw = rs2_fw_enable ? fw_val : rs2_data;

    assign mem_wr_data = rs2_data_fw;

    wire [31:0] immediate;
    wire immediate_enable;
    wire pc_enable;

    wire [2:0] alu_sel;
    wire variant_sel;
    wire [2:0] branch_sel;
    wire branch_enable;
    wire jal_enable;
    wire jalr_enable;
    
    wire [31:0] jump_offset;

    instruction_decoder decoder (
        .inst_raw(instruction),
        .nop_inject(stall),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .immediate(immediate),
        .immediate_enabled(immediate_enable),
        .pc_enabled(pc_enable),
        .alu_sel(alu_sel),
        .variant_sel(variant_sel),
        .branch_sel(branch_sel),
        .branch_en(branch_enable),
        .mem_write_en(mem_write_enable),
        .mem_read_en(mem_read_enable),
        .mem_mask_sel(mem_mask_sel),
        .reg_write_en(rf_wb_later),
        .jal_en(jal_enable),
        .jalr_en(jalr_enable),
        .jump_offset(jump_offset)
    );

    reg_file rf (
        .clk(clk),
        .we(rf_wb_enable),
        .ra1(rs1),
        .ra2(rs2),
        .wa(rf_wb_rd),
        .wd(rf_wb_data),
        .rd1(rs1_data),
        .rd2(rs2_data)
    );

    wire [31:0] alu_ina;
    wire [31:0] alu_inb;

    assign alu_ina = pc_enable ? pc_pl : rs1_data_fw;
    assign alu_inb = immediate_enable ? immediate : rs2_data_fw;
    
    alu_module alu (
        .in_A(alu_ina),
        .in_B(alu_inb),
        .alu_sel(alu_sel),
        .variant_sel(variant_sel),
        .alu_out(alu_out)
    );

    wire branch_taken;

    branch_comp bc (
        .rs1(rs1_data_fw),
        .rs2(rs2_data_fw),
        .branch_cmp_en(branch_enable),
        .branch_sel(branch_sel),
        .branch_taken(branch_taken)
    );
    
    always @(posedge clk) begin
        if (rst) begin
            stall <= 0;
        end else begin
            if (branch_taken || jal_enable || jalr_enable) begin
                stall <= 1;
            end else begin
                stall <= 0;
            end
        end 
    end
    assign pc_override = jal_enable || branch_taken || jalr_enable;
    
    always @(*) begin
        new_pc = 0;
        if (jal_enable || branch_taken) begin
            new_pc = pc_pl + jump_offset;
        end else if (jalr_enable) begin
            new_pc = rs1_data_fw + jump_offset;
        end
    end
    
endmodule
