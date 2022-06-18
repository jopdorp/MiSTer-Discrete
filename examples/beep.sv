/********************************************************************************\
 * 
 *  MiSTer Discrete example circuit - dk walk
 *
 *  Copyright 2022 by Jegor van Opdorp. 
 *  This program is free software under the terms of the GPLv3, see LICENCSE.txt
 *
 ********************************************************************************/
module beep #(
    parameter CLOCK_RATE = 1000000,
    parameter SAMPLE_RATE = 48000
)(
    input clk,
    input I_RSTn,
    input audio_clk_en,
    input beep_en,
    output reg signed[15:0] out
);
    wire signed[15:0] square_osc_out;
    wire signed[15:0] v_control;
    wire signed[15:0] mixer_input[1:0];

    wire signed[15:0] beep_en_5volts;
    wire signed[15:0] beep_en_5volts_filtered;
    assign beep_en_5volts = beep_en ? 'd6826 : 0; // 2^14 * 5/12 = 6826 , for 5 volts

    wire signed[15:0] walk_en_filtered;
    wire signed[15:0] astable_555_out;

    resistor_capacitor_low_pass_filter #(
        .SAMPLE_RATE(SAMPLE_RATE),
        .R(4700),
        .C_35_SHIFTED(219188)
    ) filter4 (
        .clk(clk),
        .I_RSTn(I_RSTn),
        .audio_clk_en(audio_clk_en),
        .in(beep_en_5volts),
        .out(beep_en_5volts_filtered)
    );

    astable_555_vco #(
        .CLOCK_RATE(CLOCK_RATE),
        .SAMPLE_RATE(SAMPLE_RATE),
        .R1(390000),
        .R2(470000),
        .C_35_SHIFTED(62)
    ) vco (
        .clk(clk),
        .I_RSTn(I_RSTn),
        .audio_clk_en(audio_clk_en),
        .v_control(beep_en_5volts_filtered + 6500),
        .out(astable_555_out)
    );

    wire signed[15:0] walk_enveloped;
    wire signed[15:0] astable_555_high_passed;

    resistor_capacitor_high_pass_filter #(
        .SAMPLE_RATE(SAMPLE_RATE),
        .R(500),
        .C_35_SHIFTED(161490)
    ) filter2 (
        .clk(clk),
        .I_RSTn(I_RSTn),
        .audio_clk_en(audio_clk_en),
        .in(astable_555_out),
        .out(astable_555_high_passed)
    );


    always @(posedge clk, negedge I_RSTn) begin
        if(!I_RSTn)begin
            out <= 0;
        end else if(audio_clk_en)begin
            out <= astable_555_high_passed & {16{beep_en}};
        end
    end

endmodule