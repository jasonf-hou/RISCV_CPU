`include "util.vh"

/**
 *  UC Berkeley EECS151 Spring 2017
 *  FPGA Project: Checkpoint 3
 *  Simple Arbiter
 *
 *  Arbitrates between CPU and XL writing to the frame buffer
 *  XL writes bypass any CPU writes
 */

module arbiter#(
    parameter mem_width = 32,
    parameter mem_depth = 32, 
    parameter mem_addr_width = `log2(mem_depth)
)(
    input           CPU_wr_en,
    input   [mem_width-1:0] CPU_wr_data,
    input   [mem_addr_width-1:0] CPU_wr_addr,

    input           XL_wr_en,
    input   [mem_width-1:0] XL_wr_data,
    input   [mem_addr_width-1:0] XL_wr_addr,

    output           frame_wr_en,
    output   [mem_width-1:0] frame_wr_data,
    output   [mem_addr_width-1:0] frame_wr_addr
);

    assign frame_wr_en = XL_wr_en || CPU_wr_en;
    assign frame_wr_addr = XL_wr_en ? XL_wr_addr : CPU_wr_addr;
    assign frame_wr_data = XL_wr_en ? frame_wr_data : CPU_wr_data; 

endmodule
