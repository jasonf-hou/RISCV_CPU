module edge_detector #(
    parameter width = 1
)(
    input clk,
    input [width-1:0] signal_in,
    output reg [width-1:0] edge_detect_pulse
);

    // This module takes a vector of 1-bit signals as input and outputs a vector of 1-bit signals. For each input signal
    // this module will look for a low to high (0->1) logic transition, and should then output a 1 clock cycle wide pulse
    // for that signal.
    // Remove this line once you have implemented this module.
    reg [width-1:0] signal_last;
    always @(posedge clk) begin
        edge_detect_pulse <= ~signal_last & signal_in; 
        
        signal_last <= signal_in;
    end
endmodule
