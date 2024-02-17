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
    parameter SAMPLE_RATE = 96000
)(
    input clk,
    input I_RSTn,
    input audio_clk_en,
    input walk_en,
    output reg signed[15:0] out = 0
);
    localparam signed[15:0] VCC = 1 << 14; // 5 volts
    wire signed[15:0] square_osc_out;
    wire signed[15:0] v_control;
    wire signed[15:0] mixer_input[1:0];

    wire signed[15:0] walk_en_5volts;
    wire signed[15:0] walk_en_5volts_filtered;
    assign walk_en_5volts =  walk_en ? 0 : VCC;

    // filter to simulate transfer rate of invertors
    rate_of_change_limiter #(
        .SAMPLE_RATE(SAMPLE_RATE),
        .MAX_CHANGE_RATE(1300)
    ) slew_rate (
        .clk(clk),
        .I_RSTn(I_RSTn),
        .audio_clk_en(audio_clk_en),
        .in(walk_en_5volts),
        .out(walk_en_5volts_filtered)
    );

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

    WalkEnAstable555 walk_en_astable (
        .clk(clk),
        .audio_clk_en(audio_clk_en),
        .I_RSTn(I_RSTn),
        .walk_en(walk_en_5volts_filtered),
        .square_wave(square_osc_out),
        .v_control(v_control)
    );

    wire signed[15:0] astable_555_out;

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
        .v_control(v_control),
        .out(astable_555_out)
    );

    wire signed[15:0] walk_en_high_passed;

    resistor_capacitor_high_pass_filter #(
        .SAMPLE_RATE(SAMPLE_RATE),
        .R(10000), // R 17
        .C_35_SHIFTED(113387) // C25 3.3uF
    ) filter7 (
        .clk(clk),
        .I_RSTn(I_RSTn),
        .audio_clk_en(audio_clk_en),
        .in(walk_en_5volts_filtered),
        .out(walk_en_high_passed)
    );

    // simulate D5 which is a 1SS53 rectifier diode
    wire signed[15:0] walk_en_rectified;
    assign walk_en_rectified = walk_en_high_passed > 0 ? walk_en_high_passed : walk_en_high_passed >> 9;


    // Simulate Q6 which is a C1815 NPN transistor, which opens at 0.6 volts
    // 2^14 * 0.6/12 = 820 , for 0.6 volts
    wire signed[15:0] walk_en_oscilated;
    assign walk_en_oscilated = astable_555_out > 820 ? walk_en_rectified : 0;

    wire signed[15:0] walk_en_oscilated_high_passed;
    
    resistor_capacitor_high_pass_filter #(
        .SAMPLE_RATE(SAMPLE_RATE),
        .R(5600), // R15
        .C_35_SHIFTED(161491) // C23 4.7uF
    ) filter8 (
        .clk(clk),
        .I_RSTn(I_RSTn),
        .audio_clk_en(audio_clk_en),
        .in(walk_en_oscilated <<< 1), // shift to add some volume
        .out(walk_en_oscilated_high_passed)
    );

    wire signed[15:0] walk_en_oscilated_band_passed;

    resistor_capacitor_low_pass_filter #(
        .SAMPLE_RATE(SAMPLE_RATE),
        .R(5600), // R16
        .C_35_SHIFTED(1614) // C22 0.047uF
    ) filter3 (
        .clk(clk),
        .I_RSTn(I_RSTn),
        .audio_clk_en(audio_clk_en),
        .in(walk_en_oscilated_high_passed),
        .out(walk_en_oscilated_band_passed)
    );

    always @(posedge clk, negedge I_RSTn) begin
        if(!I_RSTn)begin
            out <= 0;
        end else if(audio_clk_en)begin
            out <= walk_en_oscilated_band_passed;
        end
    end

endmodule