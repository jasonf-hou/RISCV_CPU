.section    .start
.global     _start

_start:

# Follow a convention
# x1 = result register 1
# x2 = result register 2
# x10 = argument 1 register
# x11 = argument 2 register
# x20 = flag register

# Test ADDI
addi x1, x0, 40
addi x2, x0, -40
li x20, 1

# Test SLTI
li x10, 0
slti x1, x10, 1
slti x2, x10, -1
li x20, 2 

# Test SLTIU
li x10, 0
sltiu x1, x10, 1
sltiu x2, x10, -1
li x20, 3

# Test XORI
li x10, 40
xori x1, x10, -8
xori x2, x10, 30
li x20, 4

# Test ORI
li x10, 20
ori x1, x10, 60 
ori x2, x10, -10 
li x20, 5

# Test ANDI
li x10, 30
andi x1, x10, 2
andi x2, x10, -99
li x20, 6

# Test SLLI
li x10, 70
slli x1, x10, 7
li x20, 7

# Test SRLI
li x10, 65
li x11, -15
srli x1, x10, 3
srli x2, x11, 3
li x20, 8

# Test SRAI
li x10, -9
li x11, 20
srai x1, x10, 3
srai x2, x11, 3
li x20, 9

# Test ADD
li x10, -9
li x11, 10
add x1, x10, x11
li x20, 10

# Test SUB
li x10, -9
li x11, 10
sub x1, x10, x11
li x20, 11

# Test SLL
li x10, 70
li x11, 7
sll x1, x10, x11
li x20, 12 

# Test SLT
li x10, 0
li x11, 1
li x12, -1
slt x1, x10, x11
slt x2, x11, x10
slt x3, x10, x12
slt x4, x11, x12
li x20, 13

# Test SLTU
li x10, 0
li x11, 1
li x12, -1
sltu x1, x10, x11
sltu x2, x11, x10
sltu x3, x10, x12
sltu x4, x11, x12
li x20, 14

# Test XOR
li x10, -1 
li x11, 77
xor x1, x10, x11
li x20, 15

# Test SRL
li x10, 65
li x11, -15
li x12, 3
srl x1, x10, x12
srl x2, x11, x12
li x20, 16

# Test SRA
li x10, -9
li x11, 20
li x12, 3
sra x1, x10, x12
sra x2, x11, x12
li x20, 17

# Test OR
li x10, 8
li x11, 99
or x1, x10, x11
li x20, 18

# Test AND
li x10, -15
li x11, 15
and x1, x10, x11
li x20, 19

# Test LUI
lui x1, 0xfffff
li x20, 20

# Test SW/LW
li x10, 77
lui x11, 0x10000
addi x11, x11, 4
sw x10, 0(x11)
addi x10, x10, -5
sw x10, -4(x11)
lw x1, 0(x11)
lw x2, -4(x11)
li x20, 21

# Test SH/LH/LHU
li x10, 30
li x11, -33
lui x12, 0x10000
sh x10, 0(x12)
sh x11, 2(x12)
lh x1, 0(x12)
lh x2, 2(x12)
lhu x3, 2(x12)
li x20, 22

# Test SB/LB/LBU
li x10, 12
li x11, -6
lui x12, 0x10000
sb x10, 0(x12)
sb x11, 3(x12)
lb x1, 0(x12)
lb x2, 3(x12)
lbu x3, 3(x12)
li x20, 23

# Test BEQ
li x10, 10
li x11, 10

li x1, 10
beq x10, x11, BEQTest1
li x1, 20
BEQTest1:

li x2, 30
beq x10, x0, BEQTest2
li x2, 10
BEQTest2:
li x20, 24

# Test BNE
li x10, 10
li x11, 10

li x1, 5
bne x10, x11, BNETest1
li x1, 10
BNETest1:

li x2, 20
bne x10, x0, BNETest2
li x2, 30
BNETest2:
li x20, 25

# Test BLT
li x10, -1
li x11, 1

li x1, 10
blt x10, x11, BLTTest1
li x1, 20
BLTTest1:

li x2, 30
blt x11, x10, BLTTest2
li x2, 40
BLTTest2:
li x20, 26

# Test BGE
li x10, 1
li x11, -1

li x1, 10
bge x10, x11, BGETest1
li x1, 20
BGETest1:

li x2, 30
bge x11, x10, BGETest2
li x2, 40
BGETest2:
li x20, 27

# Test BLTU
li x10, 1
li x11, -1

li x1, 10
bltu x10, x11, BLTUTest1
li x1, 20
BLTUTest1:

li x2, 10
bltu x11, x10, BLTUTest1
li x2, 20
BLTUTest2:
li x20, 28

# Test BGEU
li x10, -1
li x11, 1
li x1, 10
bgeu x10, x11, BGEUTest1
li x1, 20
BGEUTest1:

li x2, 10
bgeu x11, x10, BGEUTest2
li x2, 20
BGEUTest2:
li x20, 29

# Test AUIPC
auipc x10, 0 
auipc x11, 0
sub x1, x11, x10
li x20, 30

# Test JAL
auipc x10, 0 
li x1, 10
jal x11, JALTest
li x1, 20
JALTest:
sub x2, x11, x10
li x20, 31

# Test JALR
auipc x10, 0 
la x11, JALRTest
li x1, 10
jalr x12, x11, 0
li x1, 20
JALRTest:

la x13, JALRTest2
jalr x0, x13, 4
JALRTest2:
li x3, 10
li x3, 20
sub x2, x12, x10
li x20, 32

# Long JALR tests
la x10, LongTest
lui x11, 0x30000
sub x10, x10, x11
li x1, 10
jalr x0, x10
li x1, 20
LongTest:
li x20, 33

Done: j Done

