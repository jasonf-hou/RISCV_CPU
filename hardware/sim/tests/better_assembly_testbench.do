start better_assembly_testbench
file copy -force ../../../software/better_assembly_tests/assembly_tests.mif bios_mem.mif
add wave better_assembly_testbench/*
add wave better_assembly_testbench/CPU/*
add wave better_assembly_testbench/CPU/mem_ctrl/*
add wave -recursive better_assembly_testbench/CPU/cpu/*
run 1000us
