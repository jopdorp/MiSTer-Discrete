/********************************************************************************\
 * 
 *  MiSTer Discrete resistor_capacitor_low_pass filter
 *
 *  Copyright 2022 by Jegor van Opdorp. 
 *  This program is free software under the terms of the GPLv3, see LICENCSE.txt
 *          
 ********************************************************************************/
module resistor_capacitor_low_pass_filter #(
    parameter SAMPLE_RATE = 48000,
    parameter longint R = 47000,
    parameter C_35_SHIFTED = 1615, // 0.000000047 farads <<< 35 
    parameter HISTORY_LENGTH = 64
) ( 
    input clk,
    input audio_clk_en,
    input[15:0] in,
    output reg[15:0] out
);
    localparam DELTA_T_32_SHIFTED = (1 <<< 32) / SAMPLE_RATE;
    localparam R_C_32_SHIFTED = R * C_35_SHIFTED >>> 3;
    localparam longint SMOOTHING_FACTOR_ALPHA_24_SHIFTED = (DELTA_T_32_SHIFTED <<< 24) / (R_C_32_SHIFTED + DELTA_T_32_SHIFTED);
    reg[15:0] input_history[HISTORY_LENGTH-1:0];
    reg[15:0] output_history[HISTORY_LENGTH-1:0];

    always @(posedge clk) begin
        if(audio_clk_en)begin
            input_history[HISTORY_LENGTH-1] <= in;
            out <= output_history[HISTORY_LENGTH-1];
        end
    end

    initial begin
        reg[7:0] i;
        for (i = 0; i < HISTORY_LENGTH; i = i + 1) begin
            input_history[i] = 1 <<< 14;
            output_history[i] = 1 <<< 14;
        end
    end


    genvar c;
    generate
        for (c = 1; c < HISTORY_LENGTH; c = c + 1) begin: test
            always @(posedge clk) begin
                if(audio_clk_en)begin
                    output_history[c] <= output_history[c-1] + (SMOOTHING_FACTOR_ALPHA_24_SHIFTED * (input_history[c] - output_history[c-1]) >>> 24);
                    input_history[c-1] <= input_history[c];
                end
            end
        end
    endgenerate
    

endmodule