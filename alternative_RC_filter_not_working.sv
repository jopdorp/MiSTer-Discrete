/********************************************************************************\
 * 
 *  MiSTer Discrete resistor_capacitor_low_pass filter
 *
 *  Copyright 2022 by Jegor van Opdorp. 
 *  This program is free software under the terms of the GPLv3, see LICENCSE.txt
 *          
 ********************************************************************************/
module resistor_capacitor_low_pass_filter #(
    parameter CLOCK_RATE = 48000,
    parameter SAMPLE_RATE = 48000,
    parameter longint R = 47000,
    parameter C_35_SHIFTED = 1615 // 0.000000047 farads <<< 35 
) ( 
    input clk,
    input audio_clk_en,
    input[31:0] in,
    output reg[15:0] out = 0
);

    localparam TIME_STEP_35_SHIFTED = (1 <<< 35) / CLOCK_RATE;
    reg[70:0] Ir_16_SHIFTED;
    reg[63:0] intermediate_out_16_shifted;

    initial begin
        intermediate_out_16_shifted = 0;
    end

    always @(posedge clk) begin
        if (audio_clk_en) begin
            out <= intermediate_out_16_shifted >>> 16;
        end else begin
            Ir_16_SHIFTED = (((in <<< 16) - intermediate_out_16_shifted) <<< 35) / C_35_SHIFTED;
            intermediate_out_16_shifted = intermediate_out_16_shifted + Ir_16_SHIFTED * TIME_STEP_35_SHIFTED / C_35_SHIFTED;
        end
    end

endmodule
