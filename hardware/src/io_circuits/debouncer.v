`include "util.vh"

module debouncer #(
    parameter width = 1,
    parameter sample_count_max = 25000,
    parameter pulse_count_max = 150,
    parameter wrapping_counter_width = `log2(sample_count_max),
    parameter saturating_counter_width = `log2(pulse_count_max))
(
    input clk,
    input [width-1:0] glitchy_signal,
    output [width-1:0] debounced_signal
);

    // Create your debouncer circuit here
    // This module takes in a vector of 1-bit synchronized, but possibly glitchy signals
    // and should output a vector of 1-bit signals that hold high when their respective counter saturates

    reg [wrapping_counter_width:0] spg = 0;
    reg sample_now;
    
    always @(posedge clk) begin
        if (spg < sample_count_max) begin
            spg <= spg + 1;
            sample_now <= 0;
        end else begin
            spg <= 0;
            sample_now <= 1;
        end
    end
    
    integer j;
    reg [saturating_counter_width:0] ctrs [width-1:0];
    initial begin
        for (j = 0; j < width; j = j + 1) begin
            ctrs[j] = 0;
        end
    end
    genvar i;
    generate
        for (i = 0; i < width; i = i + 1) begin:COUNTERS
            always @(posedge clk) begin
                if (glitchy_signal[i] && sample_now && ctrs[i] < pulse_count_max) begin
                    ctrs[i] <= ctrs[i] + 1;
                end else if (!glitchy_signal[i]) begin
                    ctrs[i] <= 0;
                end
            end
            assign debounced_signal[i] = ctrs[i] == pulse_count_max; 
        end
    endgenerate

endmodule
