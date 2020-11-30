module frame_buffer_8_98304(
	//arbiter
	input arb_we,
	input arb_clk,
	input arb_din,
	input [19:0] arb_addr,

	//video
	input vga_clk,
	output [7:0] vga_dout,
	input [19:0] vga_addr
);
	
	wire [2:0] wea_sel = arb_addr[19:17];
	wire [7:0] mem_out;
	assign vga_dout = mem_out;

	genvar g;
	generate
		for(g = 0; g < 8; g = g + 1) begin : block_gen
			block_mem_1x98304 mem_g(
				.clka		(arb_clk),
				.wea		(arb_we && (wea_sel == g)),
				.addra		(arb_addr[16:0]),
				.dina		(arb_din),
				.douta		(),
				.clkb		(vga_clk),
				.web		(1'b0),
				.addrb		(vga_addr[16:0]),
				.dinb		(1'b0),
				.doutb		(mem_out[g])
			);
		end	
	endgenerate

endmodule