module frame_buffer_1_786432(
	//arbiter
	input arb_we,
	input arb_clk,
	input arb_din,
	input [19:0] arb_addr,

	//video
	input vga_clk,
	output vga_dout,
	input [19:0] vga_addr
);
	

	block_mem_1x786432 mem_g(
		.clka		(arb_clk),
		.wea		(arb_we),
		.addra		(arb_addr),
		.dina		(arb_din),
		.douta		(),
		.clkb		(vga_clk),
		.web		(1'b0),
		.addrb		(vga_addr),
		.dinb		(1'b0),
		.doutb		(vga_dout)
	);

endmodule
