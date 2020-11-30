`include "Opcode.vh"

module instruction_decoder(
    input [31:0] inst_raw, // Current instruction to decode
    input nop_inject, // Asserted if we want to inject a NOP into the pipeline; a NOP is represented as ADD x0, x0, x0 and does no action
    output reg [4:0] rs1, // Register number for rs1
    output reg [4:0] rs2, // Register number for rs2
    output [4:0] rd, // Register number for rd
    output reg [31:0] immediate, // Immediate value
    output reg immediate_enabled, // Asserted if we need to use the immediate value for ALU
    output reg pc_enabled, // Asserted if we need to use the PC for ALU
    output reg [2:0] alu_sel, // Determines which ALU operation we want to use
    output reg variant_sel, // Determins which variant instruction we want to use, for instructions that have variants
    output reg [2:0] branch_sel, // Determines which branch operation we want to compare
    output reg branch_en, // Asserted if the current instruction is a branching instruction
    output reg mem_write_en, // Asserted if the instruction writes data to memory
    output reg mem_read_en, // Asserted if the instruction reads data from memory (LW,LH,LB)
    output [2:0] mem_mask_sel, // 3 bit code corresponding to mask amount for writes
    output reg reg_write_en, // Asserted if the instruction will write to a regfile register
    output reg jalr_en, // Asserted if the current instruction is an unconditional absolute jump (JALR)
    output reg jal_en, // Asserted if the current instruction is an unconditional relative jump (JAL)
    output reg [31:0] jump_offset
);
    wire [31:0] instruction;
    assign instruction = nop_inject === 1 ? 32'h00000013 : inst_raw;
    assign rd = instruction[11:7];
    assign mem_mask_sel = instruction[14:12];
    
    always @(*) begin
        rs1 = instruction[19:15];
        rs2 = instruction[24:20];
        immediate_enabled = 1'b0;
        immediate = 0;
        alu_sel = `FNC_ADD_SUB;
        branch_sel = 3'b0;
        branch_en = 1'b0;
        pc_enabled = 1'b0;
        mem_write_en = 1'b0;
        mem_read_en = 1'b0;
        reg_write_en = 1'b0;
        variant_sel = 1'b0;
        jalr_en = 1'b0;
        jal_en = 1'b0;
        jump_offset = 19'b0;
        case (instruction[6:2])
            `OPC_LUI_5: begin
            alu_sel = `FNC_ADD_SUB;
		      rs1 = 0;
                // imm: high 20 bits
                immediate = {instruction[31:12], 12'b0000_0000_0000};
                immediate_enabled = 1'b1;
		reg_write_en = 1'b1;
            end
            `OPC_AUIPC_5: begin
		rs1 = 0;
                // imm: high 20 bits
                immediate = {instruction[31:12], 12'b0000_0000_0000};
                immediate_enabled = 1'b1;
		pc_enabled = 1'b1;
		reg_write_en = 1'b1;
            end
            `OPC_JAL_5: begin
		rs2 = 0;
                jump_offset = $signed({instruction[19:12], instruction[20], instruction[30:21], 1'b0});
		immediate = 32'd4;
		immediate_enabled = 1'b1;
		pc_enabled = 1'b1;
		reg_write_en = 1'b1;
		jal_en = 1'b1;
		alu_sel = `FNC_ADD_SUB;
		variant_sel = `FNC2_ADD;
            end
            `OPC_JALR_5: begin
		rs2 = 0; 
                jump_offset = $signed({instruction[31:20]});
		immediate = 32'd4;
		immediate_enabled = 1'b1;
		pc_enabled = 1'b1;
		reg_write_en = 1'b1;
		jalr_en = 1'b1;
		alu_sel = `FNC_ADD_SUB;
		variant_sel = `FNC2_ADD;
            end
            `OPC_BRANCH_5: begin
                // imm: sign extended bottom 12 bits shifted left by 1
                jump_offset = $signed({instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0});
		branch_sel = instruction[14:12];
		branch_en = 1'b1;
		pc_enabled = 1'b1;
            end
            `OPC_STORE_5: begin
                // imm: sign extended bottom 12 bits
                immediate = {{21{instruction[31]}}, instruction[30:25], instruction[11:7]};
                immediate_enabled = 1'b1; 
		      mem_write_en = 1'b1;
           end
            `OPC_LOAD_5: begin
                // imm: sign extended bottom 12 bits
                rs2 = 0;
                immediate = {{21{instruction[31]}}, instruction[30:20]};
                immediate_enabled = 1'b1;
	           	mem_read_en = 1'b1;
		        reg_write_en = 1'b1;
            end
            `OPC_ARI_RTYPE_5: begin
                // imm: none
                immediate = 32'hXXXX_XXXX;
                alu_sel = instruction[14:12];
		reg_write_en = 1'b1;
		variant_sel = instruction[30];
	    end
            `OPC_ARI_ITYPE_5: begin
                if (instruction[14:12] == `FNC_SLL || instruction[14:12] == `FNC_SRL_SRA) begin
		    // imm: zero extended bottom 5 bits
		    immediate = instruction[24:20];
		    variant_sel = instruction[30];
		end else begin
                    // imm: sign extended bottom 12 bits
                    immediate = $signed({instruction[31:20]});
                end
                immediate_enabled = 1'b1;
                alu_sel = instruction[14:12];
		reg_write_en = 1'b1;
            end
        endcase
    end
endmodule
