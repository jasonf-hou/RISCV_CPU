module binary2gray #(parameter WID = 8) (
    input [WID-1:0] binary_in,
    output [WID-1:0] gray_out
    );

   assign gray_out = binary_in ^ (binary_in >> 1);

endmodule
