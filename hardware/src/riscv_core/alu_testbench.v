`timescale 1ns / 1ps
`include "Opcode.vh"

module ALU_testbench();
    parameter period = 20; // 1/50MHz = 20ns
    reg clk; // 50MHz
    
    // clock generation
    initial clk = 0;
    always #(period/2) clk = ~clk;
    
    reg [31:0] in_A;
    reg [31:0] in_B;
    
    reg [2:0] fnc3;
    reg fnc2;
    
    wire [31:0] result;
    
    reg [31:0] reference;
    // instantiate ALU module
    alu_module alu(
        .in_A(in_A),
        .in_B(in_B),
        .fnc3(fnc3),
        .fnc2(fnc2),
        .result(result));

    integer i;
    
    reg [30:0] rand_31;
    reg [14:0] rand_15;
    reg [31:0] A, B;
    reg[4*8:0] type;
    
    task checkOutput;
    input reg[4*8:0] type;
        if (result == reference)
            $display("PASS %s: \tA: 0x%h, B: 0x%h, result: 0x%h, reference: 0x%h", type, A, B, result, reference);
        else begin
            $display("FAIL %s: \tA: 0x%h, B: 0x%h, result: 0x%h, reference: 0x%h", type, A, B, result, reference);
            $finish();
        end
    endtask
    initial begin
        in_A = 32'b0;
        in_B = 32'b0;
        fnc3 = 3'b0;
        fnc2 = 1'b0;
        for(i = 0; i < 20; i = i + 1) begin
             $display("Test %d", i);
            @(posedge clk);
            // A and B are made negative to check signed ops
            rand_31 = {$random} & 31'h7FFFFFFF;
            rand_15 = {$random} & 15'h7FFF;
            A = {1'b1, rand_31};
            B = {16'hFFFF, 1'b1, rand_15};
            in_A = A;
            in_B = B;  
                      
            //Test ADD:
            type = "ADD";
            fnc3 = `FNC_ADD_SUB;
            fnc2 = `FNC2_ADD;
            reference = A + B;
            #1
            checkOutput(type);
            //Test SUB:
            type = "SUB";
            fnc2 = `FNC2_SUB;
            reference = A - B;
            #1         
            checkOutput(type);
            //Test SLL:
            type = "SLL";
            fnc3 = `FNC_SLL;
            reference = A << B[4:0];
            #1         
            checkOutput(type);
            //Test SLT:
            type = "SLT";
            fnc3 = `FNC_SLT;
            reference = $signed(A) < $signed(B);  
            #1         
            checkOutput(type);
            //Test SLTU:
            type = "SLTU";
            fnc3 = `FNC_SLTU;
            reference = A < B;
            #1         
            checkOutput(type);
            //Test XOR:
            type = "XOR";
            fnc3 = `FNC_XOR;
            reference = A ^ B;
            #1         
            checkOutput(type);
            //Test OR:
            type = "OR";
            fnc3 = `FNC_OR;
            reference = A | B;
            #1         
            checkOutput(type);
            //Test AND:
            type = "AND";
            fnc3 = `FNC_AND;
            reference = A & B;
            #1         
            checkOutput(type);
            //Test SRL:
            type = "SRL";
            fnc3 = `FNC_SRL_SRA;
            fnc2 = `FNC2_SRL;
            reference = A >> B[4:0];
            #1         
            checkOutput(type);
            //Test SRA:
            type = "SRA";
            fnc2 = `FNC2_SRA;
            reference = ($signed(A) >>> B[4:0]);                      
            #1         
            checkOutput(type);    
        end
        $finish();
    end
endmodule 
