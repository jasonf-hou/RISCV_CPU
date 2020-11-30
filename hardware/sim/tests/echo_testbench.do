start echo_testbench
file copy -force ../../../software/echo/echo.mif imem_blk_ram.mif
file copy -force ../../../software/echo/echo.mif dmem_blk_ram.mif
file copy -force ../../../software/echo/echo.mif bios_mem.mif
add wave echo_testbench/*
add wave echo_testbench/CPU/*
add wave -recursive echo_testbench/CPU/cpu/*
add wave -recursive echo_testbench/CPU/mem_ctrl/*
add wave -recursive echo_testbench/CPU/on_chip_uart/*
add wave echo_testbench/off_chip_uart/*
run 10000us
