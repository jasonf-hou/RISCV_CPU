module reg_file (
    input clk,
    input we,
    input [4:0] ra1, ra2, wa,
    input [31:0] wd,
    output [31:0] rd1, rd2
);
    (* ram_style = "distributed" *) reg [31:0] registers [31:0];
    
    assign rd1 = ra1 == 0 ? 32'h00000000 : registers[ra1];
    assign rd2 = ra2 == 0 ? 32'h00000000 : registers[ra2];
    
    always @(posedge clk) begin
        if (we) begin
            if (wa != 5'b0) begin
                registers[wa] <= wd;
            end else begin
                registers[wa] <= 32'b0;
            end
        end else begin
            registers[wa] <= registers[wa];
        end
    end
endmodule
