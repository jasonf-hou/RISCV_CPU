module mem_wr_decoder(
    input [2:0] fnc,
    input [31:0] addr,
    input [31:0] wr_data,

    output reg [31:0] wr_dout,
    output reg [3:0] wr_mask,
    output reg invalid_addr
);

    always @(*) begin
        invalid_addr = 0;
        case (fnc)
        `FNC_SW: begin
            wr_dout = wr_data;
            wr_mask = 4'b1111;
        end
        `FNC_SH: begin
            case (addr[1:0])
                2'b00: begin
                    wr_mask = 4'b0011;
                    wr_dout = wr_data[15:0];
                end
                2'b01: begin
                    wr_mask = 4'b0110;
                    wr_dout = {8'h00, wr_data[15:0], 8'h00 };
                end
                2'b10: begin
                    wr_mask = 4'b1100;
                    wr_dout = {wr_data[15:0], 16'h0000};
                end
                default: begin
                    wr_mask = 0;
                    wr_dout = 0;
                    invalid_addr = 1'b1;
                end
            endcase
        end
        `FNC_SB: begin
            case (addr[1:0])
            // need to format bitstring according to offset
                2'b00: begin
                    wr_mask = 4'b0001;
                    wr_dout = wr_data[7:0];
                end
                2'b01: begin
                    wr_mask = 4'b0010;
                    wr_dout = {16'h0000, wr_data[7:0], 8'h00};
                end
                2'b10: begin
                    wr_mask = 4'b0100;
                    wr_dout = {8'h00, wr_data[7:0], 16'h0000};
                end
                2'b11: begin
                    wr_mask = 4'b1000;
                    wr_dout = {wr_data[7:0], 24'h000000};
                end
            endcase
        end
        default: begin
            wr_mask = 0;
            wr_dout = 0;
            invalid_addr = 1'b1;
        end
        endcase
    end
endmodule
