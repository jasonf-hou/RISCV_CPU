module tone_generator (
    input output_enable,
    input [23:0] tone_switch_period,
    input clk,
    input rst,
    output square_wave_out
);

    reg [23:0] clock_counter = 0;
    reg wave = 0;

    assign square_wave_out = output_enable && (tone_switch_period != 24'd0) ? wave : 1'b0;

    always @ (posedge clk) begin
        clock_counter <= clock_counter;
        wave <= wave;
        if (rst) begin
            clock_counter <= 0;
            wave <= 0;
        end
        else begin
            if (clock_counter > tone_switch_period) begin
                clock_counter <= 0;
                wave <= ~wave;
            end
            else begin
                clock_counter <= clock_counter + 1;
            end
        end
    end
endmodule
