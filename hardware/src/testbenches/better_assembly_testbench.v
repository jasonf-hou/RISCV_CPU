`timescale 1ns/10ps

/* MODIFY THIS LINE WITH THE HIERARCHICAL PATH TO YOUR REGFILE ARRAY INDEXED WITH reg_number */
`define REGFILE_ARRAY_PATH CPU.cpu.dex.rf.registers[reg_number]

module better_assembly_testbench();
    reg clk, rst;
    parameter CPU_CLOCK_PERIOD = 20;
    parameter CPU_CLOCK_FREQ = 50_000_000;

    initial clk = 0;
    always #(CPU_CLOCK_PERIOD/2) clk <= ~clk;

    Riscv151 # (
        .CPU_CLOCK_FREQ(CPU_CLOCK_FREQ)
    ) CPU(
        .clk(clk),
        .rst(rst),
        .FPGA_SERIAL_RX(),
        .FPGA_SERIAL_TX()
    );

    // A task to check if the value contained in a register equals an expected value
    task check_reg;
        input [4:0] reg_number;
        input [31:0] expected_value;
        input [10:0] test_num;
        if (expected_value !== `REGFILE_ARRAY_PATH) begin
            $display("FAIL - test %d, got: %d, expected: %d for reg %d", test_num, `REGFILE_ARRAY_PATH, expected_value, reg_number);
            $finish();
        end
        else begin
            $display("PASS - test %d, got: %d for reg %d", test_num, expected_value, reg_number);
        end
    endtask

    // A task that runs the simulation until a register contains some value
    task wait_for_reg_to_equal;
        input [4:0] reg_number;
        input [31:0] expected_value;
        while (`REGFILE_ARRAY_PATH !== expected_value) @(posedge clk);
    endtask

    initial begin
        rst = 0;

        // Reset the CPU
        rst = 1;
        repeat (30) @(posedge clk);             // Hold reset for 30 cycles
        rst = 0;

        // Your processor should begin executing the code in /software/assembly_tests/start.s

	// Test ADDI
	wait_for_reg_to_equal(20, 32'd1);
	check_reg(1, 32'd40, 1);
	check_reg(2, -32'sd40, 2);

	// Test SLTI
	wait_for_reg_to_equal(20, 32'd2);
	check_reg(1, 32'd1, 3);
	check_reg(2, 32'd0, 4);
	
	// Test SLTIU
	wait_for_reg_to_equal(20, 32'd3);
	check_reg(1, 32'd1, 5);
	check_reg(2, 32'd1, 6);

	// Test XORI
	wait_for_reg_to_equal(20, 32'd4);
	check_reg(1, 32'd40 ^ (-32'sd8), 7);
	check_reg(2, 32'd40 ^ 32'd30, 8);
        
	// Test ORI
	wait_for_reg_to_equal(20, 32'd5);
	check_reg(1, 32'd20 | 32'd60, 9);
	check_reg(2, 32'd20 | (-32'sd10), 10);
	
	// Test ANDI
	wait_for_reg_to_equal(20, 32'd6);
	check_reg(1, 32'd30 & 32'd2, 11);
	check_reg(2, 32'd30 & (-32'sd99), 12);

	// Test SLLI
	wait_for_reg_to_equal(20, 32'd7);
	check_reg(1, 32'd70 << 7, 13);

	// Test SRLI
	wait_for_reg_to_equal(20, 32'd8);
	check_reg(1, 32'd65 >> 3, 14);
	check_reg(2, (-32'd15) >> 3, 15);

	// Test SRAI 	
	wait_for_reg_to_equal(20, 32'd9);
	check_reg(1, (-32'sd9) >>> 3, 16);
	check_reg(2, 32'd20 >>> 3, 17);

	// Test ADD
	wait_for_reg_to_equal(20, 32'd10);
	check_reg(1, 1, 18);
	
	// Test SUB
	wait_for_reg_to_equal(20, 32'd11);
	check_reg(1, -32'd19, 19);

	// Test SLL
	wait_for_reg_to_equal(20, 32'd12);
	check_reg(1, 32'd70 << 7, 20);

	// Test SLT
	wait_for_reg_to_equal(20, 32'd13);
	check_reg(1, 1, 21);
	check_reg(2, 0, 22);
	check_reg(3, 0, 23);
	check_reg(4, 0, 24);

	// Test SLTU
	wait_for_reg_to_equal(20, 32'd14);
	check_reg(1, 1, 25);
	check_reg(2, 0, 26);
	check_reg(3, 1, 27);
	check_reg(4, 1, 28);

	// Test XOR
	wait_for_reg_to_equal(20, 32'd15);
	check_reg(1, ~32'd77, 29);

	// Test SRL
	wait_for_reg_to_equal(20, 32'd16);
	check_reg(1, 32'd65 >> 3, 30);
	check_reg(2, (-32'd15) >> 3, 31);

	// Test SRA
	wait_for_reg_to_equal(20, 32'd17);
	check_reg(1, (-32'sd9) >>> 3, 32);
	check_reg(2, 32'd20 >>> 3, 33);

	// Test OR
	wait_for_reg_to_equal(20, 32'd18);
	check_reg(1, 8 | 99, 34);

	// Test AND
	wait_for_reg_to_equal(20, 32'd19);
	check_reg(1, 1, 35);

	// Test LUI
	wait_for_reg_to_equal(20,32'd20);
	check_reg(1, 32'hfffff000, 36);	

	// Test SW/LW
	wait_for_reg_to_equal(20, 32'd21);
	check_reg(1, 32'd77, 37);	
	check_reg(2, 32'd72, 38);	

	// Test SH/LH/LHU
	wait_for_reg_to_equal(20, 32'd22);
	check_reg(1, 32'd30, 39);
	check_reg(2, -32'd33, 40);
	check_reg(3, {16'd0, (-32'd33) & 16'hffff}, 41);

	// Test SB/LB/LBU
	wait_for_reg_to_equal(20, 32'd23);
	check_reg(1, 32'd12, 42);
	check_reg(2, -32'd6, 43);
	check_reg(3, {24'd0, (-32'd6) & 8'hff}, 44);

	// Test BEQ
	wait_for_reg_to_equal(20, 32'd24);
	check_reg(1, 32'd10, 45);
	check_reg(2, 32'd10, 46);

	// Test BNE
	wait_for_reg_to_equal(20, 32'd25);
	check_reg(1, 32'd10, 47);
	check_reg(2, 32'd20, 48);

	// Test BLT
	wait_for_reg_to_equal(20, 32'd26);
	check_reg(1, 32'd10, 49);
	check_reg(2, 32'd40, 50);

	// Test BGE
	wait_for_reg_to_equal(20, 32'd27);
	check_reg(1, 32'd10, 51);
	check_reg(2, 32'd40, 52);

	// Test BLTU
	wait_for_reg_to_equal(20, 32'd28);
	check_reg(1, 32'd10, 53);
	check_reg(2, 32'd20, 54);

	// Test BGEU
	wait_for_reg_to_equal(20, 32'd29);
	check_reg(1, 32'd10, 55);
	check_reg(2, 32'd20, 56);

	// Test AUIPC
	wait_for_reg_to_equal(20, 32'd30);
	check_reg(1, 32'd4, 57);

	// Test JAL
	wait_for_reg_to_equal(20, 32'd31);
	check_reg(1, 32'd10, 58);
	check_reg(2, 32'd12, 59);
	
	// Test JALR
	wait_for_reg_to_equal(20, 32'd32);
	check_reg(1, 32'd10, 60);
	check_reg(2, 32'd20, 61);
	check_reg(3, 32'd20, 62);

	// Long JALR
	wait_for_reg_to_equal(20, 32'd33);
	check_reg(1, 32'd10, 63);

        $display("ALL ASSEMBLY TESTS PASSED");
        $finish();
    end
endmodule
