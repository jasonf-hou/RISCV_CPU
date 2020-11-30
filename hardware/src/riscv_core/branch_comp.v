`timescale 1ns / 1ps
`include "Opcode.vh"

module branch_comp(
    input [31:0] rs1,
    input [31:0] rs2,
    input [2:0] branch_sel,
    input branch_cmp_en,
    
    output branch_taken
    );
    
    reg branch_pass;
    wire bc_en;
    
    assign branch_taken = branch_pass;
    assign bc_en = branch_cmp_en;
    
    always @(*) begin
        if (bc_en == 1'b1) begin
            case (branch_sel)
                `FNC_BEQ: branch_pass = (rs1 == rs2);
                `FNC_BNE: branch_pass = (rs1 != rs2);
                `FNC_BLT: branch_pass = ($signed(rs1) < $signed(rs2));
                `FNC_BGE: branch_pass = ($signed(rs1) >= $signed(rs2));
                `FNC_BLTU: branch_pass = (rs1 < rs2);
                `FNC_BGEU: branch_pass = (rs1 >= rs2);
                default: branch_pass = 0;
            endcase
         end else branch_pass = 0;
    end
endmodule
