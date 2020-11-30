`timescale 1ns/100ps

`define SECOND 1000000000
`define MS 1000000
`define BIT_DEPTH 24

// This testbench runs a program on your CPU which transmits samples to the
// I2S controller FIFO. The program transmits PCM samples -50, -49, -48, ...,
// 0, 1, 2, ..., 48, 49, 50. You should inspect the waveform and verify that
// the I2S controller receives each sample in order.
module i2s_integration_testbench();
  parameter SYSTEM_CLK_PERIOD = 8;
  parameter SYSTEM_CLK_FREQ = 125_000_000;
  
  // System clock domain I/O
  reg system_clock = 0;
  reg system_reset = 0;
  
  wire mclk, sclk, lrck, sdin;

  // Generate system clock
  always #(SYSTEM_CLK_PERIOD/2) system_clock = ~system_clock;

  reg [`BIT_DEPTH-1:0] pcm_data;
  reg  left_valid, right_valid;
  wire left_ready, right_ready;
  
  wire [5:0] leds;

  // We instantiate the top module of our system design to test it. It should
  // contain your RISC-V CPU, an async FIFO, and the I2S controller.
  z1top #(
    .SYSTEM_CLOCK_FREQ(SYSTEM_CLK_FREQ),
    .B_SAMPLE_COUNT_MAX(1),
    .B_PULSE_COUNT_MAX(1)
  ) top (
    .USER_CLK(system_clock),
    .RESET(system_reset),
    .BUTTONS(4'b0),
    .SWITCHES(2'b0),
    .LEDS(leds),
    .FPGA_SERIAL_RX(1'b1),
    .FPGA_SERIAL_TX(),
    .MCLK(mclk),
    .LRCK(lrck),
    .SCLK(sclk),
    .SDIN(sdin),
    .AUDIO_PWM()
  );

  initial begin
    // Pulse the system reset to the i2s controller
    @(posedge system_clock);
    system_reset = 1'b1;
    repeat (10) @(posedge system_clock);
    system_reset = 1'b0;
    repeat (10) @(posedge system_clock);

    // Inspect the waveform to see that all the PCM samples were sent and
    // that the async FIFO is empty!!
    repeat (256 * 10) @(posedge sclk);

    $finish();
  end
endmodule
