module pipe #(
    parameter N = 1
)(
    input clk, // System clock
    input rst, // System reset

    input [N - 1:0] input_val,
    output [N - 1:0] output_val
);
    reg [N - 1:0] pipeline_val;

    assign output_val = pipeline_val;
    always @(posedge clk) begin
	if (rst) begin
	    pipeline_val <= 0;
	end else begin
	    pipeline_val <= input_val;
	end
    end	
endmodule
