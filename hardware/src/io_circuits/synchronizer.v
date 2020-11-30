module synchronizer #(parameter width = 1) (
    input [width-1:0] async_signal,
    input clk,
    output [width-1:0] sync_signal
);
    // Create your 2 flip-flop synchronizer here
    // This module takes in a vector of 1-bit asynchronous (from different clock domain or not clocked) signals
    // and should output a vector of 1-bit synchronous signals that are synchronized to the input clk

    // Remove this line once you create your synchronizer
    //assign sync_signal = 0;
    reg [width-1:0] sync1;
    reg [width-1:0] sync2;
    assign sync_signal = sync2;
    always @ (posedge clk) begin
        sync1 <= async_signal;
        sync2 <= sync1;
    end
endmodule
