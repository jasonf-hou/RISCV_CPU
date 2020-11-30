`include "Opcode.vh"

module alu_module (
        input [31:0] in_A,in_B,

        input [2:0] alu_sel,
        input variant_sel,

        output [31:0] alu_out
  );

  reg [31:0] alu_result;

  assign alu_out = alu_result;

  always @(*) begin
        case (alu_sel)
        `FNC_ADD_SUB: begin
            if (variant_sel == `FNC2_ADD) alu_result = in_A + in_B;
            else alu_result = in_A - in_B; 
        end
        `FNC_SLL: begin
            alu_result = in_A << in_B;
        end
        `FNC_SLT: begin
            if ($signed(in_A) < $signed(in_B)) alu_result = 1;
            else alu_result = 0;
        end
        `FNC_SLTU: begin
            if (in_A < in_B) alu_result = 1;
            else alu_result = 0;
        end
        `FNC_XOR: alu_result = in_A ^ in_B;
        `FNC_OR: alu_result = in_A | in_B;
        `FNC_AND: alu_result = in_A & in_B;
        `FNC_SRL_SRA: begin
            if (variant_sel == `FNC2_SRL) alu_result = in_A >> in_B;
            else alu_result = $signed(in_A) >>> in_B;
        end
        default: alu_result = 0;
        endcase
    end
endmodule