module dk_walk(
    input clk,
    input audio_clk_en,
    input walk_en,
    output[15:0] out
);
    wire[15:0] square_osc_out;
    wire[15:0] v_control;
    wire[15:0] vco_out;
    wire[15:0] mixer_input[1:0];

    assign mixer_input[0] = walk_en ? 'd27307 : 0; // 2^16 * 5/12 = 27307 , for 5 volts
    assign mixer_input[1] = vco_out;


    invertor_square_wave_oscilator#(
        .CLOCK_RATE(1000000),
        .SAMPLE_RATE(48000),
        .R1(4300),
        .C_16_SHIFTED(655360)
    ) square (
        .clk(clk),
        .audio_clk_en(audio_clk_en),
        .out(square_osc_out)
    );

    resistive_two_way_mixer #(
        .R0(10000),
        .R1(12000)
    ) mixer (
        .clk(clk),
        .audio_clk_en(audio_clk_en),
        .inputs(mixer_input),
        .out(v_control)
    );

    astable_555_vco #(
        .CLOCK_RATE(1000000),
        .SAMPLE_RATE(48000),
        .R1(47000),
        .R2(27000),
        .C_35_SHIFTED(1134)
    ) vco (
        .clk(clk),
        .audio_clk_en(audio_clk_en),
        .v_control(v_control),
        .out(out)
    );



endmodule