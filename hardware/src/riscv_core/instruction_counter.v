module instruction_counter(
    input clk,
    input rst,
    input stall_detected,
    input reset_counters,

    output reg [31:0] instr_counter,
    output reg [31:0] cycle_counter
    );
    // logic for resetting the counter
    
     always @ (posedge clk) begin
         if (rst || reset_counters) instr_counter <= 0;
         else if (!stall_detected) instr_counter <= instr_counter + 1; // increment if not stalling
         else instr_counter <= instr_counter;
         if (rst || reset_counters) cycle_counter <= 0;
         else cycle_counter <= cycle_counter + 1;
     end
     
endmodule
