/********************************************************************************\
 * 
 *  MiSTer Discrete resistive two way mixer
 *
 *  Copyright 2022 by Jegor van Opdorp. 
 *  This program is free software under the terms of the GPLv3, see LICENCSE.txt
 *
 *   inputs[0]    inputs[1]
 *        V         V
 *        |         |       
 *        |         |       
 *        Z         Z
 *     R0 Z         Z R1
 *        Z         Z
 *        |         |
 *        '----,----'
 *             |
 *             |
 *             V
 *            out
 *          
 ********************************************************************************/
module resistive_two_way_mixer #(
    parameter longint R0 = 10000,
    parameter R1 = 10000
) ( 
    input clk,
    input[15:0] inputs[1:0],
    output reg[15:0] out
);
    localparam longint R0_RATIO_16_SHIFTED = ((R1 <<< 16) / R0);
    localparam longint R1_RATIO_16_SHIFTED = ((R0 <<< 16) / R1);
    localparam longint NORMALIZATION_RATIO_16_SHIFTED = (1 <<< 32)/(R0_RATIO_16_SHIFTED+R1_RATIO_16_SHIFTED);

    always @(posedge clk) begin
        out <= (R0_RATIO_16_SHIFTED * inputs[0] + R1_RATIO_16_SHIFTED * inputs[1]) * NORMALIZATION_RATIO_16_SHIFTED >>> 32;
    end
endmodule