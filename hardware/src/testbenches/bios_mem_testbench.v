`timescale 1ns/100ps

`define SECOND 1000000000
`define MS 1000000

`define CLK_PERIOD 8

`define MAX_ADDR_READ 

module bios_mem_testbench(

    );
   reg clk = 0;
   always #(`CLK_PERIOD/2) clk = ~clk;
   
   reg [11:0] addra = 0, addrb = 0;
   wire [31:0] douta, doutb;
      
   bios_mem BIOS(
      .ena(1'b1),
      .enb(1'b1),
      .clka(clk),  
      .clkb(clk),  
      .addra(addra),     //12-bit, from I stage
      .douta(douta),           //32-bit, to mux to I stage (instruction)
      .addrb(addrb),       //12-bit, from datapath
      .doutb(doutb)          //32-bit, to mux to M stage ("dataout from mem")
      );
    
    always @(posedge clk) begin 
        addra <= addra + 1;
        addrb <= addrb + 1;
    end
    
    initial begin:TB
        // This testbench just reads out the data in the RAM so that
        //   - you have an example of how to use the IP; and
        //   - you can check if it matches the contents match the .coe file you expect.
    end   
    
endmodule
