// This converter on works on 32 bits or fewer.

module gray2binary #(parameter WID = 8) (    
    input [WID-1:0] gray_in,
    output [WID-1:0] binary_out
    );

   wire [WID-1:0]    shift1, shift2, shift3, shift4;

   // For the purposes of the converter, we will probably not need a case where we'll need the shift by 16 (used as FIFO pointers so we'll probably not need 2^16 entries in FIFO)
   /*
   assign shift1 = gray_in ^ (gray_in >> 16);
   assign shift2 = shift1 ^ (shift1 >> 8);
   assign shift3 = shift2 ^ (shift2 >> 4);
   assign shift4 = shift3 ^ (shift3 >> 2);
   assign binary_out = shift4 ^ (shift4 >> 1);
    */

   assign shift1 = gray_in ^ (gray_in >> 8);
   assign shift2 = shift1 ^ (shift1 >> 4);
   assign shift3 = shift2 ^ (shift2 >> 2);
   assign binary_out = shift3 ^ (shift3 >> 1);

endmodule
