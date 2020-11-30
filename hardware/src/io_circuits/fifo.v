`include "util.vh"

module fifo #(
    parameter data_width = 8,
    parameter fifo_depth = 32,
    parameter addr_width = `log2(fifo_depth)
)(
    input clk, rst,
    // Write side
    input wr_en,
    input [data_width-1:0] din,
    output full,
    // Read side
    input rd_en,
    output [data_width-1:0] dout,
    output empty
);
    reg [addr_width:0] write_ptr;
    reg [addr_width:0] read_ptr;
    reg [addr_width:0] length;
    reg [data_width:0] data [fifo_depth-1:0];

    assign full = length == fifo_depth;
    assign empty = length == 0;
        
    assign dout = data[(read_ptr - 1 + fifo_depth) % fifo_depth]; 

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            write_ptr = 0;
	       read_ptr = 0;
            length = 0;
        end else begin
            if (wr_en && !full) begin
                data[write_ptr] = din;
                write_ptr = (write_ptr + 1) % fifo_depth;
                length = length + 1;
            end else begin
                data[write_ptr] = data[write_ptr];
                write_ptr = write_ptr;
                length = length;
            end
            
            if (rd_en && !empty) begin
                read_ptr = (read_ptr + 1) % fifo_depth;
                length = length - 1;
            end else begin
                read_ptr = read_ptr;
                length = length;
            end
        end
    end
endmodule
