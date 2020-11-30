start echo_integration_testbench
file copy -force ../../../software/echo/echo.mif imem_blk_ram.mif
file copy -force ../../../software/echo/echo.mif dmem_blk_ram.mif
file copy -force ../../../software/echo/echo.mif bios_mem.mif
add wave echo_integration_testbench/*
add wave echo_integration_testbench/top/*
add wave echo_integration_testbench/off_chip_uart/*
add wave echo_integration_testbench/top/CPU/mem_ctrl/*
add wave echo_integration_testbench/top/CPU/on_chip_uart/*
add wave echo_integration_testbench/top/CPU/cpu/*
run 10000us
