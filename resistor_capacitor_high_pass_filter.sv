/********************************************************************************\
 * 
 *  MiSTer Discrete resistor_capacitor_high_pass filter
 *
 *  Copyright 2022 by Jegor van Opdorp. 
 *  This program is free software under the terms of the GPLv3, see LICENCSE.txt
 *
 *  based on https://en.wikipedia.org/wiki/High-pass_filter
 *          
 ********************************************************************************/
module resistor_capacitor_high_pass_filter #(
    parameter CLOCK_RATE = 50000000,
    parameter SAMPLE_RATE = 48000,
    parameter R = 47000,
    parameter C_35_SHIFTED = 113387 // 0.0000033 farads <<< 35 
) ( 
    input clk,
    input audio_clk_en,
    input signed[15:0] in,
    output reg signed[15:0] out = 0
);
    localparam DELTA_T_32_SHIFTED = (1 <<< 32) / SAMPLE_RATE;
    localparam R_C_32_SHIFTED = R * C_35_SHIFTED >>> 3;
    localparam signed SMOOTHING_FACTOR_ALPHA_16_SHIFTED = (R_C_32_SHIFTED <<< 16) / (R_C_32_SHIFTED + DELTA_T_32_SHIFTED);
    localparam HISTORY_LENGTH = CLOCK_RATE / SAMPLE_RATE;

    reg signed[15:0] input_history[HISTORY_LENGTH-1:0];
    reg signed[15:0] output_history[HISTORY_LENGTH-1:0];

    reg[23:0] c = 2;

    initial begin
        reg[7:0] i;
        for (i = 0; i < HISTORY_LENGTH; i = i + 1) begin
            input_history[i] = 0;
            output_history[i] = 0;
        end
    end

    genvar i;
    generate
        for (i = 1; i < HISTORY_LENGTH; i = i + 1) begin: test
            always @(posedge clk) begin
                if(audio_clk_en)begin
                    input_history[i-1] <= input_history[i];
                end
            end
        end
    endgenerate

    always @(posedge clk) begin
        if(audio_clk_en)begin
            input_history[HISTORY_LENGTH-1] <= in;
            out <= output_history[HISTORY_LENGTH-1];
            c <= 2;
        end else begin
            if (c < HISTORY_LENGTH) begin
                c <= c + 1;
                output_history[c] <= get_updated_sample(output_history[c-1], input_history[c], input_history[c-1]);
            end
        end
    end
    
    function reg signed[15:0] get_updated_sample(reg signed[15:0] previous_out, in, previous_in);
        return SMOOTHING_FACTOR_ALPHA_16_SHIFTED * (previous_out + in - previous_in) >> 16;
    endfunction

endmodule