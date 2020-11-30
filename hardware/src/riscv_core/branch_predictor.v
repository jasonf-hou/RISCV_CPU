module branch_predictor(
    input clk,	// Global clock
    input rst,  // Global reset
    
    input branch_enable, // Determines whether the current pc needs to be considered w.r.t branching
    input branch_taken, // Asserted if we actually needed to branch

    output branch_now // Asserted when predict we are going to take a branch
);

    assign branch_now = branch_enable ? 1 : 0; // Predict always-branch for now

endmodule
