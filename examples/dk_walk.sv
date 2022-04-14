module dk_walk(
    input clk,
    input audio_clk_en,
    input walk_en,
    output reg[15:0] out
);
    localparam CLOCK_RATE = 1000000;
    
    wire[15:0] square_osc_out;
    wire[15:0] v_control;
    wire[15:0] vco_out;
    wire[15:0] mixer_input[1:0];

    wire[15:0] walk_en_5volts;
    assign walk_en_5volts =  walk_en ? 'd27307 : 0;
    assign mixer_input[0] = walk_en_5volts; // 2^16 * 5/12 = 27307 , for 5 volts
    assign mixer_input[1] = vco_out;


    wire[15:0] walk_en_filtered;
    wire[15:0] astable_555_out;

    invertor_square_wave_oscilator#(
        .CLOCK_RATE(CLOCK_RATE),
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
        .out(astable_555_out)
    );

    resistor_capacitor_high_pass_filter #(
        .CLOCK_RATE(CLOCK_RATE),
        .R(10000),
        .C_35_SHIFTED(113387)
    ) filter1 (
        clk,
        audio_clk_en,
        walk_en_5volts,
        walk_en_filtered
    );

    reg[15:0] walk_enveloped;
    wire[15:0] walk_enveloped_high_passed;

    resistor_capacitor_high_pass_filter #(
        .CLOCK_RATE(CLOCK_RATE),
        .R(5600),
        .C_35_SHIFTED(161491)
    ) filter2 (
        clk,
        audio_clk_en,
        walk_enveloped,
        walk_enveloped_high_passed
    );

    wire[15:0] walk_enveloped_band_passed;

    resistor_capacitor_low_pass_filter  #(
        .CLOCK_RATE(CLOCK_RATE),
        .R(5600),
        .C_35_SHIFTED(1614)
    ) filter3 (
        clk,
        audio_clk_en,
        walk_enveloped_high_passed,
        walk_enveloped_band_passed
    );


    always @(posedge clk) begin
        walk_enveloped <= walk_en_filtered * astable_555_out;
        if(audio_clk_en)begin
            out <= walk_enveloped_band_passed;
        end
    end

endmodule