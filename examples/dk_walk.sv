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
    input I_RSTn,
    input audio_clk_en,
    input walk_en,
    output reg signed[15:0] out = 0
);
    wire signed[15:0] square_osc_out;
    wire signed[15:0] v_control;
    wire signed[15:0] mixer_input[1:0];

    wire signed[15:0] walk_en_5volts;
    wire signed[15:0] walk_en_5volts_filtered;
    assign walk_en_5volts =  walk_en ? 0 : 'd6826; // 2^14 * 5/12 = 6826 , for 5 volts

    // filter to simulate transfer rate of invertors
    rate_of_change_limiter #(
        .SAMPLE_RATE(SAMPLE_RATE),
        .MAX_CHANGE_RATE(950)
    ) slew_rate (
        .clk(clk),
        .I_RSTn(I_RSTn),
        .audio_clk_en(audio_clk_en),
        .in(walk_en_5volts),
        .out(walk_en_5volts_filtered)
    );

    assign mixer_input[0] = walk_en_5volts_filtered; 
    assign mixer_input[1] = square_osc_out;

    localparam SAMPLE_RATE_SHIFT = 3;
    localparam INTEGRATOR_SAMPLE_RATE = SAMPLE_RATE >> SAMPLE_RATE_SHIFT;

    wire signed[15:0] walk_en_filtered;
    wire signed[15:0] astable_555_out;

    invertor_square_wave_oscilator#(
        .CLOCK_RATE(CLOCK_RATE),
        .SAMPLE_RATE(SAMPLE_RATE),
        .R1(4300),
        .C_MICROFARADS_16_SHIFTED(655360)
    ) square (
        .clk(clk),
        .I_RSTn(I_RSTn),
        .audio_clk_en(audio_clk_en),
        .out(square_osc_out)
    );

    resistive_two_way_mixer #(
        .R0(10000),
        .R1(12000)
    ) mixer (
        .clk(clk),
        .I_RSTn(I_RSTn),
        .audio_clk_en(audio_clk_en),
        .inputs(mixer_input),
        .out(v_control)
    );

    wire signed[15:0] v_control_filtered;

    resistor_capacitor_low_pass_filter #(
        .SAMPLE_RATE(SAMPLE_RATE),
        .R(1200),
        .C_35_SHIFTED(113387)
    ) filter4 (
        .clk(clk),
        .I_RSTn(I_RSTn),
        .audio_clk_en(audio_clk_en),
        .in(v_control),
        .out(v_control_filtered)
    );

    astable_555_vco #(
        .CLOCK_RATE(CLOCK_RATE),
        .SAMPLE_RATE(SAMPLE_RATE),
        .R1(47000),
        .R2(27000),
        .C_35_SHIFTED(1134) // C28
    ) vco (
        .clk(clk),
        .I_RSTn(I_RSTn),
        .audio_clk_en(audio_clk_en),
        //TODO: properly calculate the resistor mesh R44, R45, R46, this is calibrated by ear now. 
        //      It influences the range, so the lowest and the highest notes in the walk sound
        .v_control(v_control_filtered + 16'd6200),
        .out(astable_555_out)
    );

    resistor_capacitor_high_pass_filter #(
        .SAMPLE_RATE(SAMPLE_RATE),
        // setting this lower allows more of the aftertone, setting it higher makes a shorter and bulkier sound
        // Might actually need to be appluied to the  square wave osc and the walk_en before they are mixed together
        // related to mesh R44, R45, R46
        // Chose (R46=12K) + (R44=1.2K) = 13.2K 
        .R(13200),
        .C_35_SHIFTED(113387) // C29
    ) filter1 (
        .clk(clk),
        .I_RSTn(I_RSTn),
        .audio_clk_en(audio_clk_en),
        .in(walk_en_5volts_filtered),
        .out(walk_en_filtered)
    );

    wire signed[15:0] walk_enveloped;
    // FIXME hack to simulate diondes coming from 555 output
    assign walk_enveloped = astable_555_out > 2000 ? walk_en_filtered : 0;
    
    wire signed[15:0] walk_enveloped_high_passed;

    resistor_capacitor_high_pass_filter #(
        .SAMPLE_RATE(SAMPLE_RATE),
        .R(2000),
        .C_35_SHIFTED(161491)
    ) filter2 (
        .clk(clk),
        .I_RSTn(I_RSTn),
        .audio_clk_en(audio_clk_en),
        .in(walk_enveloped <<< 1),
        .out(walk_enveloped_high_passed)
    );

    wire signed[15:0] walk_enveloped_band_passed;

    resistor_capacitor_low_pass_filter #(
        .SAMPLE_RATE(SAMPLE_RATE),
        .R(5600),
        .C_35_SHIFTED(1614)
    ) filter3 (
        .clk(clk),
        .I_RSTn(I_RSTn),
        .audio_clk_en(audio_clk_en),
        .in(walk_enveloped_high_passed),
        .out(walk_enveloped_band_passed)
    );

    always @(posedge clk, negedge I_RSTn) begin
        if(!I_RSTn)begin
            out <= 0;
        end else if(audio_clk_en)begin
            //FIXME: hack to simulate diode connection coming from ground
            if(walk_enveloped_band_passed > 0) begin 
                out <= walk_enveloped_band_passed;
            end else begin
                out <= (walk_enveloped_band_passed >>> 1) - (walk_enveloped_band_passed >>> 6);
            end
        end
    end

endmodule