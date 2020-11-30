`timescale 1ns / 1ps

module mem_r_decoder(
    // This decoder takes the output of a memory read and chooses whether to return a full half or byte to 
    // the wb stage
    input [2:0] fnc, // selects LB,LH,LW,LBU,LHU
    input [1:0] byte_offset, // selects between word, half word, and byte, should be last two bits of alu_out in top
    input [31:0] raw_data, // raw data for load register offset
    
    output [31:0] data_out
    );
    reg [31:0] dout_reg;
    assign data_out = dout_reg;
    
    always @(*) begin
        case (fnc)
            `FNC_LW: dout_reg = raw_data;
            `FNC_LH:
                case (byte_offset)
                    2'b00: dout_reg = {{16{raw_data[15]}}, raw_data[15:0]};
                    2'b01: dout_reg = {{16{raw_data[23]}}, raw_data[23:8]};
                    2'b10: dout_reg = {{16{raw_data[31]}}, raw_data[31:16]};
                default: dout_reg = 32'b0;
                endcase
            `FNC_LB:
                case (byte_offset)
                    2'b00: dout_reg = {{24{raw_data[7]}}, raw_data[7:0]};
                    2'b01: dout_reg = {{24{raw_data[15]}}, raw_data[15:8]};
                    2'b10: dout_reg = {{24{raw_data[23]}}, raw_data[23:16]};
                    2'b11: dout_reg = {{24{raw_data[31]}}, raw_data[31:24]};
                default: dout_reg = 32'b0;
                endcase
            `FNC_LHU:
                case (byte_offset)
                    2'b00: dout_reg = {{16{1'b0}}, raw_data[15:0]};
                    2'b01: dout_reg = {{16{1'b0}}, raw_data[23:8]};
                    2'b10: dout_reg = {{16{1'b0}}, raw_data[31:16]};
                default: dout_reg = 32'b0;
                endcase
            `FNC_LBU:
                case (byte_offset)
                    2'b00: dout_reg = {{24{1'b0}}, raw_data[7:0]};
                    2'b01: dout_reg = {{24{1'b0}}, raw_data[15:8]};
                    2'b10: dout_reg = {{24{1'b0}}, raw_data[23:16]};
                    2'b11: dout_reg = {{24{1'b0}}, raw_data[31:24]};
                default: dout_reg = 32'b0;
                endcase
            default: dout_reg = 32'b0;
        endcase
    end
endmodule
