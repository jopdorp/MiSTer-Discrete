/********************************************************************************\
 * 
 *  MiSTer Discrete resistor_capacitor_low_pass filter
 *
 *  Copyright 2022 by Jegor van Opdorp. 
 *  This program is free software under the terms of the GPLv3, see LICENCSE.txt
 *         
 *  based on https://en.wikipedia.org/wiki/Low-pass_filter
 *  and https://zipcpu.com/dsp/2017/08/19/simple-filter.html
 * 
 ********************************************************************************/
module resistor_capacitor_low_pass_filter #(
    /* verilator lint_off WIDTH */
    parameter[63:0] SAMPLE_RATE = 48000 * 2,
    parameter R = 47000,
    parameter C_35_SHIFTED = 1615 // 0.000000047 farads <<< 35 
) ( 
    input clk,
    input I_RSTn,
    input audio_clk_en,
    input signed[15:0] in,
    output reg signed[15:0] out = 0
);
    localparam longint DELTA_T_32_SHIFTED = (1 <<< 32) / SAMPLE_RATE;
    localparam longint R_C_32_SHIFTED = R * C_35_SHIFTED >>> 3;
    localparam longint LONG_SMOOTHING_FACTOR = (DELTA_T_32_SHIFTED <<< 16) / (R_C_32_SHIFTED + DELTA_T_32_SHIFTED);

    localparam signed [29:0] SMOOTHING_FACTOR_ALPHA_16_SHIFTED = {1'b0, LONG_SMOOTHING_FACTOR[28:0]};

    
    reg signed[15:0] difference_in_out /*verilator public*/;
    /* verilator lint_off UNUSED */
    reg signed[29:0] smoothed;

    always@(posedge clk, negedge I_RSTn) begin
        if(!I_RSTn)begin
            out <= 0;
        end else if(audio_clk_en)begin
            out <= out + {smoothed[29], smoothed[14:0]};
        end else begin
            difference_in_out  <= in - out;
            smoothed  <= (SMOOTHING_FACTOR_ALPHA_16_SHIFTED * difference_in_out >>> 16);
        end
    end
    
endmodule 