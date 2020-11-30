`include "Opcode.vh"

module hazard_control (
    input [4:0] ex_rs1, ex_rs2,
    input [4:0] ma_rd,
    input ma_rf_wb_en,
    input [31:0] ma_rd_val,
    input ma_load_en,
    output [31:0] forward_value_ex,
    output ex_rs1_fwd, ex_rs2_fwd
);
    assign forward_value_ex = ma_rd_val;
    assign ex_rs1_fwd = !ma_load_en && ma_rf_wb_en && ex_rs1 != 0 && ex_rs1 == ma_rd;
    assign ex_rs2_fwd = !ma_load_en && ma_rf_wb_en && ex_rs2 != 0 && ex_rs2 == ma_rd;
endmodule
