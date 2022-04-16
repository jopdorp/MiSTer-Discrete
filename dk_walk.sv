/********************************************************************************\
 * 
 *  MiSTer Discrete example circuit - dk walk
 *
 *  Copyright 2022 by Jegor van Opdorp. 
 *  This program is free software under the terms of the GPLv3, see LICENCSE.txt
 *
 ********************************************************************************/
module dk_walk #(
    parameter CLOCK_RATE = 1000000,
    parameter SAMPLE_RATE = 48000
)(
    input clk,
    input audio_clk_en,
    input walk_en,
    output reg signed[15:0] out = 0
);
    wire integrator_en;
    wire signed[15:0] square_osc_out;
    wire signed[15:0] v_control;
    wire signed[15:0] mixer_input[1:0];

    wire signed[15:0] walk_en_5volts;
    assign walk_en_5volts =  walk_en ? 'd6826 : 0; // 2^14 * 5/12 = 6826 , for 5 volts
    assign mixer_input[0] = walk_en_5volts; 
    assign mixer_input[1] = square_osc_out;

    localparam SAMPLE_RATE_SHIFT = 3;
    localparam INTEGRATOR_SAMPLE_RATE = SAMPLE_RATE >>> SAMPLE_RATE_SHIFT;
    reg[SAMPLE_RATE_SHIFT:0] integrator_en_divider = 0;
    assign integrator_en = audio_clk_en && integrator_en_divider == 0;


    wire signed[31:0] walk_en_filtered;
    wire signed[15:0] astable_555_out;

    invertor_square_wave_oscilator#(
        .CLOCK_RATE(CLOCK_RATE),
        .SAMPLE_RATE(SAMPLE_RATE),
        .R1(4300),
        .C_MICROFARADS_16_SHIFTED(655360)
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
        .CLOCK_RATE(CLOCK_RATE),
        .SAMPLE_RATE(SAMPLE_RATE),
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
        .SAMPLE_RATE(INTEGRATOR_SAMPLE_RATE),
        .R(10000),
        .C_35_SHIFTED(113387)
    ) filter1 (
        .clk(clk),
        .audio_clk_en(integrator_en && (astable_555_out > 1000)),
        .in(walk_en_5volts),
        .out(walk_en_filtered)
    );

    wire signed[15:0] walk_enveloped;
    assign walk_enveloped = astable_555_out > 1000 ? walk_en_filtered : 0;
    
    wire signed[15:0] walk_enveloped_high_passed;

    resistor_capacitor_high_pass_filter #(
        .CLOCK_RATE(CLOCK_RATE),
        .SAMPLE_RATE(SAMPLE_RATE),
        .R(5600),
        .C_35_SHIFTED(161491)
    ) filter2 (
        clk,
        audio_clk_en,
        walk_enveloped,
        walk_enveloped_high_passed
    );

    wire signed[15:0] walk_enveloped_band_passed;

    resistor_capacitor_low_pass_filter #(
        .CLOCK_RATE(CLOCK_RATE),
        .SAMPLE_RATE(SAMPLE_RATE),
        .R(5600),
        .C_35_SHIFTED(1614)
    ) filter3 (
        clk,
        audio_clk_en,
        walk_enveloped_high_passed,
        walk_enveloped_band_passed
    );

    always @(posedge clk) begin
        if(audio_clk_en)begin
            integrator_en_divider = integrator_en_divider + 1;
            out <= walk_enveloped_band_passed;
        end
    end

endmodule