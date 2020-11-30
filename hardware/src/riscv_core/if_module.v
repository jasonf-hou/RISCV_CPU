module if_module(
    input clk,
    input rst,

    // Pipeline inputs
    input [31:0] new_pc,
    input pc_override,
    
    // Pipeline outputs
    output [31:0] pc
);
    reg [31:0] curr_pc;
    reg [31:0] next_pc;

    always @(posedge clk) begin
        if (rst) begin
            curr_pc <= 32'h40000000;
        end else if (pc_override) begin
            curr_pc <= new_pc;
        end else begin
            curr_pc <= next_pc;
        end
    end

    always @(*) begin
        if (rst) begin
            next_pc = 32'h40000000;
        end else if (pc_override) begin
            next_pc = new_pc + 4;
        end else begin
            next_pc = pc + 4;
        end
    end

    assign pc = curr_pc;
endmodule
