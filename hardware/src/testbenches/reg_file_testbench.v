`timescale 1ns/100ps

module reg_file_testbench(); 
    reg clk = 0;
    always #(1) clk = ~clk;

    reg we;
    reg [4:0] ra1, ra2, wa;
    reg [31:0] wd;
    
    wire [31:0] rd1, rd2;
    
    reg_file DUT (.clk(clk),
		  .we(we),
		  .ra1(ra1),
		  .ra2(ra2),
		  .wa(wa),
		  .wd(wd),
		  .rd1(rd1),
		  .rd2(rd2));
    
    integer i;
    initial begin
        $display("Writing to regfile...");
        ra1 = 5'd0;
        ra2 = 5'd0;
        wa = 5'd0;
        wd = 32'hFFFFFFFF;
        we = 1'b1;
        @(posedge clk);
        
        for (i = 1; i < 32; i = i + 1) begin
            ra1 = i;
            ra2 = i;
            wa = i;
            wd = { i[7:0], i[7:0], i[7:0], i[7:0] };
            @(posedge clk);
            if (rd1 == wd && rd2 == wd) begin
                $display("Test x%d PASS: %08x == %08x", wa, rd1, wd);
            end else begin
                $display("Test x%d FAIL: %08x == %08x", wa, rd1, wd);
            end
        end
        
        $display("Reading from regfile...");
        we = 1'b0;
        for (i = 0; i < 32; i = i + 1) begin // Positive testing
            ra1 = i;
            ra2 = i;
            wa = i;
            wd = { i[7:0], i[7:0], i[7:0], i[7:0] };
            @(posedge clk);
            if (rd1 == wd && rd2 == wd) begin
               $display("Test x%d PASS: %08x == %08x", wa, rd1, wd);
            end else begin
               $display("Test x%d FAIL: %08x == %08x", wa, rd1, wd);
            end
        end
        for (i = 0; i < 32; i = i + 1) begin // Negative testing
            ra1 = i;
            ra2 = i;
            wa = i;
            wd = ~{ i[7:0], i[7:0], i[7:0], i[7:0] };
            @(posedge clk);
            if (rd1 != wd && rd2 != wd) begin
                $display("Test x%d PASS: %08x != %08x", wa, rd1, wd);
            end else begin
                $display("Test x%d FAIL: %08x != %08x", wa, rd1, wd);
            end
        end
    end
endmodule
