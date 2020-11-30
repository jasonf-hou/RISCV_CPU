`include "util.vh"

module uart_transmitter #(
    parameter CLOCK_FREQ = 125_000_000,
    parameter BAUD_RATE = 115_200)
(
    input clk,
    input reset,

    input [7:0] data_in,
    input data_in_valid,
    output reg data_in_ready,

    output serial_out
);
    // See diagram in the lab guide
    localparam  SYMBOL_EDGE_TIME    =   CLOCK_FREQ / BAUD_RATE;
    localparam  CLOCK_COUNTER_WIDTH =   `log2(SYMBOL_EDGE_TIME);
    
    
    reg [9:0] sr;
    reg [CLOCK_COUNTER_WIDTH:0] ctr;
    
    reg [3:0] idx;
    
    reg sclk;
    
    reg sending;
    
    reg firstcyc;

    assign serial_out = !sending || sr[0];
        
    always @(posedge clk) begin
        if  (reset || !sending) begin
            ctr = 0;
            sr = {1'b1, data_in, 1'b0};
            idx = 0;
            firstcyc = 1;
        end else begin
            if (firstcyc) begin
                sr = {1'b1, data_in, 1'b0};
                firstcyc = 0;
            end else begin
                firstcyc = 0;
            end
        
            if (ctr == SYMBOL_EDGE_TIME) begin
                sr = sr >> 1;
                idx = idx + 1;
                ctr = 0;
            end else begin
                sr = sr;
                idx = idx;
                ctr = ctr + 1;
            end
        end
    end
    
    always @(posedge clk) begin
        if (reset) begin
            sending = 0;
            data_in_ready = 1;
        end else begin 
            if (data_in_ready && data_in_valid) begin
                sending = 1;
                data_in_ready = 0;
            end else if (idx > 9) begin
                sending = 0;
                data_in_ready = 1;
            end else begin
                sending = sending;
                data_in_ready = data_in_ready;
            end
        end
    end


endmodule
