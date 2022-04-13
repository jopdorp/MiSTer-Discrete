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
    parameter R = 10000,
    parameter C = 10000,
    parameter HISTORY_LENGTH = 64
) ( 
    input clk,
    input audio_clk_en,
    input[15:0] in,
    output reg[15:0] out
);
    localparam DELTA_T_32_SHIFTED = (1 <<< 32) / SAMPLE_RATE;
    localparam R_C_32_SHIFTED = R * C <<< 32;
    localparam SMOOTHING_FACTOR_ALPHA_32_SHIFTED = DELTA_T_32_SHIFTED / (R_C_32_SHIFTED + DELTA_T_32_SHIFTED);
    reg[15:0] input_history[HISTORY_LENGTH-1:0];
    reg[15:0] output_history[HISTORY_LENGTH-1:0];

    always @(posedge clk) begin
        if(audio_clk_en)begin
            input_history[HISTORY_LENGTH-1] <= in;
        end
    end

    genvar c;
    generate
        for (c = 1; c < HISTORY_LENGTH - 1; c = c + 1) begin: test
            initial begin
                input_history[c] = 0;
                output_history[c] = 0;
            end

            always @(posedge clk) begin
                if(audio_clk_en)begin
                    output_history[c] <= output_history[c-1] + (SMOOTHING_FACTOR_ALPHA_32_SHIFTED * (input_history[c] - output_history[c-1]) >>> 32);
                end
            end
        end
    endgenerate

    always @(posedge clk) begin
        if(audio_clk_en)begin
            
        end
    end

endmodule