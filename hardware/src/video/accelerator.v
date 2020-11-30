`include "util.vh"

/*
 *
 *  Implemenets the basic Bresenham line-drawing algorithm
 *  Note: x0 must be less than x1. Otherwise, nothing will be drawn.
 *
 *  Currently designed for single color
 *  To modify for multicolor, change the color components and how they are written.
 * 
 * https://www.tutorialspoint.com/computer_graphics/line_generation_algorithm.htm
 */

module accelerator #(
    parameter pixel_width = 1024,
    parameter pixel_height = 768,
    parameter pixel_width_bits = `log2(pixel_width),   //10-bit
    parameter pixel_height_bits = `log2(pixel_height), //10-bit

    parameter mem_width = 1,
    parameter mem_depth = 786432, 
    parameter mem_addr_width = `log2(mem_depth)
)(
    input   clk,
    //no reset

    //Pixel data
    input [pixel_width_bits - 1 : 0] x0,
    input [pixel_height_bits - 1 : 0] y0,
    input [pixel_width_bits - 1 : 0] x1,
    input [pixel_height_bits - 1 : 0] y1,
    input color,
    
    //CPU interface
    output RX_ready,
    input  RX_valid,    //fire signal

    //Arbiter Interface
    output   XL_wr_en,
    output   [mem_width-1:0] XL_wr_data,
    output   [mem_addr_width-1:0] XL_wr_addr  
);

    reg [pixel_width_bits - 1 : 0] x_curr;
    reg [pixel_height_bits - 1 : 0] y_curr;
    reg [pixel_width_bits - 1 : 0] x_target;
    reg [pixel_height_bits - 1 : 0] y_target;
       
    reg [pixel_width_bits : 0] pk_step_L = 0;
    reg [pixel_height_bits : 0] pk_step_U = 0;
    

    reg [pixel_width_bits : 0] px = 0;

    reg color_reg;
    reg TX_running;

    // No cheating.
endmodule
