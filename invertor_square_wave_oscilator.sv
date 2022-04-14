/*********************************************************************************\
 *  
 *  MiSTer Discrete invertor square wave oscilator
 *
 *  Copyright 2022 by Jegor van Opdorp. 
 *  This program is free software under the terms of the GPLv3, see LICENCSE.txt
 *
 *
 *  Simplified model of the below circuit.
 *  This model does not take the  transfer functions of the invertors 
 *  into account:
 * 
 *  f = 1 / 2.2 R1C1
 *  This equation was found on:
 *  https://www.gadgetronicx.com/square-wave-generator-logic-gates/
 *  
 *  The equation didn't coincide with the circuit simulated version.
 *  It looks like the above formula is to obtain the SWITCHING feequency.
 *  The actualy frequency is twice lower.
 *
 *        |\        |\
 *        | \       | \
 *     +--|  >o--+--|-->o--+-------> out
 *     |  | /    |  | /    |
 *     |  |/     |  |/     |
 *     Z         Z         |
 *     Z         Z R1     --- C
 *     Z         Z        --- 
 *     |         |         |
 *     '---------+---------'
 *
 *     Drawing based on a drawing from MAME discrete
 *
 *********************************************************************************/
module invertor_square_wave_oscilator#(
    parameter CLOCK_RATE = 50000000,
    parameter SAMPLE_RATE = 48000,
    parameter R1 = 4300,
    parameter C_16_SHIFTED = 655360 // 10 microfarad
) (
    input clk,
    input audio_clk_en,
    output reg[15:0] out = 0
);
    localparam longint R1_K_OHM_16_SHIFTED = R1 * 16777 >>> 8; // 1/1000 <<< 24 = 16777
    localparam CONSTANT_RATIO_16_SHIFTED = 14895; // 1/2.2/2 * 2 ^ 16
    localparam longint FREQUENCY_16_SHIFTED = CONSTANT_RATIO_16_SHIFTED * (R1_K_OHM_16_SHIFTED * C_16_SHIFTED) >>> 32;
    localparam WAVE_LENGTH = (CLOCK_RATE <<< 16) / FREQUENCY_16_SHIFTED;
    localparam HALF_WAVE_LENGTH = WAVE_LENGTH >>> 1;

    reg [63:0] wave_length_counter = 0;

    always @(posedge clk) begin
        if(wave_length_counter < WAVE_LENGTH)begin
           wave_length_counter <= wave_length_counter + 1;
        end else begin 
            wave_length_counter <= 0;
        end

        if (audio_clk_en) begin
            out <=  {16{wave_length_counter < HALF_WAVE_LENGTH}};
        end
    end
endmodule