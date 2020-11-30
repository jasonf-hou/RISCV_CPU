`include "util.vh"

module i2s_controller #(
  parameter SYS_CLOCK_FREQ = 125_000_000,
  parameter LRCK_FREQ_HZ = 88_200,
  parameter MCLK_TO_LRCK_RATIO = 128,
  parameter BIT_DEPTH = 24,
  parameter BIT_DEPTH_WIDTH = `log2(BIT_DEPTH)
) (
  input sys_reset,
  input sys_clk,            // Source clock, from which others are derived

  input [BIT_DEPTH-1:0] pcm_data,
  input pcm_data_valid,
  output pcm_data_ready,

  // I2S control signals
  output mclk,              // Master clock for the I2S chip
  output sclk,
  output lrck,              // Left-right clock, which determines which channel each audio datum is sent to.
  output sdin               // Serial audio data.
);


    // An idea of what you might need, to get you started.
    localparam MCLK_FREQ_HZ = LRCK_FREQ_HZ * MCLK_TO_LRCK_RATIO;
    localparam MCLK_CYCLES = `divceil(SYS_CLOCK_FREQ, MCLK_FREQ_HZ);
    localparam MCLK_CYCLES_HALF = `divceil(MCLK_CYCLES, 2);
    localparam MCLK_COUNTER_WIDTH = `log2(MCLK_CYCLES);

    //localparam LRCK_CYCLES = `divceil(SYS_CLOCK_FREQ, LRCK_FREQ_HZ);
    localparam LRCK_CYCLES = MCLK_CYCLES * MCLK_TO_LRCK_RATIO;
    localparam LRCK_CYCLES_HALF = `divceil(LRCK_CYCLES, 2);
    localparam LRCK_COUNTER_WIDTH = `log2(LRCK_CYCLES);

    //localparam SCLK_FREQ_HZ = LRCK_FREQ_HZ * BIT_DEPTH * 2;
    //localparam SCLK_CYCLES = `divceil(SYS_CLOCK_FREQ, SCLK_FREQ_HZ);
    localparam SCLK_CYCLES = LRCK_CYCLES / (BIT_DEPTH * 2);
    localparam SCLK_CYCLES_HALF = `divceil(SCLK_CYCLES, 2);
    localparam SCLK_COUNTER_WIDTH = `log2(SCLK_CYCLES);

    reg [MCLK_COUNTER_WIDTH:0] mclk_counter;
    reg mclk_buffer;
    reg [LRCK_COUNTER_WIDTH:0] lrck_counter;
    reg lrck_buffer;
    reg [SCLK_COUNTER_WIDTH:0] sclk_counter;
    reg sclk_buffer;
    reg [BIT_DEPTH_WIDTH:0] bit_counter;
    reg [BIT_DEPTH_WIDTH:0] data_counter;
    reg sdin_buffer;
    reg data_ready_buffer;
    reg left;

    initial begin
        mclk_counter = 0;
        mclk_buffer = 0;
        lrck_counter = 0;
        lrck_buffer = 0;
        sclk_counter = 0;
        sclk_buffer = 0;
        bit_counter = 0;
        data_ready_buffer = 0;
        left = 1;
        sdin_buffer = 0;
        data_counter = 0;
    end

    assign mclk = mclk_buffer;
    assign lrck = lrck_buffer;
    assign sclk = sclk_buffer;
    //assign sdin = bit_counter;
    assign sdin = sdin_buffer;
    assign pcm_data_ready = data_ready_buffer;

    // 1: Generate MCLK from sys_clk. MCLK's frequency must be an integer multiple
    // of the sample rate, and hence LRCK rate, as defined in the PMOD I2S reference
    // manual and the Cirrus Logic CS4344 data sheet.
    always @(posedge sys_clk) begin
        if (sys_reset) begin
            mclk_buffer <= 0;
            mclk_counter <= 0;
        end else if (mclk_counter >= MCLK_CYCLES_HALF - 1) begin
            mclk_buffer <= !mclk_buffer;
            mclk_counter <= 0;
        end else mclk_counter <= mclk_counter + 1;
    end

    // 2: Generate the LRCK, the left-right clock.
    always @(posedge sys_clk) begin
        if (sys_reset) begin
            lrck_buffer <= 0;
            lrck_counter <= 0;
        end else if (lrck_counter >= LRCK_CYCLES_HALF - 1) begin
            lrck_buffer <= !lrck_buffer;
            lrck_counter <= 0;
        end else lrck_counter <= lrck_counter + 1;
    end

    // 3. Generate the bit clock, or serial clock. It clocks transmitted bits for a
    // whole sample on each half-cycle of the lr_clock. The frequency of this clock
    // relative to the lr_clock determines how wide our samples can be.
    always @(posedge sys_clk) begin
        if (sys_reset) begin
            sclk_buffer <= 0;
            sclk_counter <= 0;
        end else if (sclk_counter >= SCLK_CYCLES_HALF - 1) begin
            sclk_buffer <= !sclk_buffer;
            sclk_counter <= 0;
        end else sclk_counter <= sclk_counter + 1;
    end

    always @(negedge sclk_buffer) begin
        if (sys_reset) begin
            bit_counter <= 0;
            data_ready_buffer <= 1'b0;
            left <= 1;
        end

        if (lrck_counter == 2'd0) begin
            bit_counter <= 0;
            data_ready_buffer <= 1'b0;
            left <= !left;
        end
        else begin
            bit_counter <= bit_counter + 1;
        end

        if (bit_counter == 1'b0 && left) begin
            data_ready_buffer <= 1'b1;
        end

        else begin
            data_ready_buffer <= 1'b0;
        end

        if (pcm_data_valid) begin
            sdin_buffer <= pcm_data[BIT_DEPTH-1-bit_counter];
        end
    end

endmodule
