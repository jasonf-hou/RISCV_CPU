start assembly_testbench
file copy -force ../../../software/assembly_tests/assembly_tests.mif imem_blk_ram.mif
file copy -force ../../../software/assembly_tests/assembly_tests.mif dmem_blk_ram.mif
file copy -force ../../../software/assembly_tests/assembly_tests.mif bios_mem.mif
add wave assembly_testbench/*
add wave assembly_testbench/CPU/*
add wave -recursive assembly_testbench/CPU/cpu/*
run 100us

