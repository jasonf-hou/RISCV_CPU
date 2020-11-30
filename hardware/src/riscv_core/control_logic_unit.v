`timescale 1ns / 1ps
`include "Opcode.vh"

module control_logic_unit(
    input [31:0] instruction, // 32 bit instruction
    input branch_en, // from branch_comp

    output [1:0] op1_sel, // select op2 (2b'00 = original rs1 data, 2'b01 = u_type imm)
    output [1:0] op2_sel, // select op1 inputs (2b'00 = original rs2 data, 2b'01 = u_type imm, 2'b10 = s_type sign-extended imm, 2'b11 = PC)

    output [1:0] wb_sel, // selects wb dest (2b'00 = PC, 2b'01 = alu_out, 2b'10 = mem_rData)
    output pc_src, // selects wb source for pc (2b'00 = PC + 4, 2b'01 = branch, 2b'10 = jump)
    output reg_wen, // enables register writ to reg file
    output mem_rw_en, // enables read or write from dmem

    output [2:0] alu_fnc3, // forwards fnc3
    output alu_fnc2, // forwards 'fnc2'

    output [1:0] wa_sel, //rd or x1
    output [2:0] load_fnc
    );

    reg [1:0] op1_sel_reg;
    reg [1:0] op2_sel_reg;
    reg [1:0] wb_sel_reg;
    reg pc_src_reg;
    reg [2:0] alu_fnc3_reg;
    reg alu_fnc2_reg;
    reg reg_wen_reg;
    reg [2:0] load_fnc_reg;
    reg mem_wen_reg;
    reg branch_reg;

    assign op1_sel = op1_sel_reg;
    assign op2_sel = op2_sel_reg;
    assign wb_sel = wb_sel_reg;
    assign pc_src = pc_src_reg;
    assign alu_fnc3 = alu_fnc3_reg;
    assign alu_fnc2 = alu_fnc2_reg;
    assign reg_wen = reg_wen_reg;
    assign load_fnc = load_fnc_reg;
    assign mem_wen = mem_wen_reg;
    assign branch = branch_reg;


    always @(*) begin
        case (instruction[6:0])
        `OPC_LUI: begin
        end
        `OPC_AUIPC: begin
        end
        `OPC_JAL: begin
        end
        `OPC_JALR: begin
        end
        `OPC_BRANCH: begin
        end
        `OPC_STORE: begin
        end
        `OPC_LOAD: begin
        end
        `OPC_ARI_RTYPE: begin
            //op1_sel =
        end
        `OPC_ARI_ITYPE: begin
        end
        default: begin
            op1_sel_reg = 2'b00;
            op2_sel_reg = 2'b00;
            wb_sel_reg = 2'b00;

        end
        endcase
    end
endmodule
