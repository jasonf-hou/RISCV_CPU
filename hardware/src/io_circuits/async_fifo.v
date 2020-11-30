`include "util.vh"

module async_fifo #(
    parameter data_width = 8,
    parameter fifo_depth = 32,
    parameter addr_width = `log2(fifo_depth)
) (
    input wr_clk,
    input rd_clk,

    input wr_en,
    input rd_en,
    input [data_width-1:0] din,

    output full,
    output empty,
    output reg [data_width-1:0] dout
);

   reg [data_width-1:0]       buff [fifo_depth-1:0];

   reg [addr_width:0]     rd_to_wr_reg1 = 0;
   reg [addr_width:0]     rd_to_wr_reg2 = 0;
   reg [addr_width:0]     wr_to_rd_reg1 = 0;
   reg [addr_width:0]     wr_to_rd_reg2 = 0;
   reg [addr_width:0]     rd_ptr = 0;
   reg [addr_width:0]     wr_ptr = 0;

   wire [addr_width:0]    bin_rd_ptr;
   wire [addr_width:0]    gray_rd_ptr;
   wire [addr_width:0]    bin_wr_ptr;
   wire [addr_width:0]    gray_wr_ptr;
   wire [addr_width:0]    synced_bin_rd_ptr;
   wire [addr_width:0]    synced_gray_rd_ptr;
   wire [addr_width:0]    synced_bin_wr_ptr;
   wire [addr_width:0]    synced_gray_wr_ptr;

   binary2gray #(.WID(addr_width+1)) read_b2g_converter(
                         .binary_in(bin_rd_ptr),
                         .gray_out(gray_rd_ptr));

   binary2gray #(.WID(addr_width+1)) write_b2g_converter(
                          .binary_in(bin_wr_ptr),
                          .gray_out(gray_wr_ptr));

   gray2binary #(.WID(addr_width+1)) read_g2b_converter(
                         .gray_in(synced_gray_wr_ptr),
                         .binary_out(synced_bin_wr_ptr));

   gray2binary #(.WID(addr_width+1)) write_g2b_converter(
                         .gray_in(synced_gray_rd_ptr),
                         .binary_out(synced_bin_rd_ptr));

   assign bin_rd_ptr = rd_ptr;
   assign bin_wr_ptr = wr_ptr;
   assign synced_gray_rd_ptr = rd_to_wr_reg2;
   assign synced_gray_wr_ptr = wr_to_rd_reg2;
   assign empty = (synced_bin_wr_ptr[addr_width-1:0] == bin_rd_ptr[addr_width-1:0])
     && (synced_bin_wr_ptr[addr_width] == bin_rd_ptr[addr_width]);
   assign full = (synced_bin_rd_ptr[addr_width-1:0] == bin_wr_ptr[addr_width-1:0])
     && (synced_bin_rd_ptr[addr_width] != bin_wr_ptr[addr_width]);
  
   always@(posedge wr_clk) begin
    {rd_to_wr_reg1, rd_to_wr_reg2} <= {gray_rd_ptr,rd_to_wr_reg1};      
   end

   always@(posedge rd_clk) begin
      {wr_to_rd_reg1, wr_to_rd_reg2} <= {gray_wr_ptr,wr_to_rd_reg1};      
   end

   always@(posedge wr_clk) begin
      if(~full & wr_en) wr_ptr <= wr_ptr + 1;
   end

   always@(posedge rd_clk) begin
      if(~empty & rd_en) rd_ptr <= rd_ptr + 1;
   end

   always@(posedge wr_clk) begin
      if (~full & wr_en) buff[wr_ptr[addr_width-1:0]] <= din;
   end

   always@(posedge rd_clk) begin
      if (~empty & rd_en )dout <= buff[rd_ptr[addr_width-1:0]];
   end
   
endmodule
