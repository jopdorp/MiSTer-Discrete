/********************************************************************************\
 * 
 *  MiSTer Discrete invertor square wave oscilator test bench
 *
 *  Copyright 2022 by Jegor van Opdorp. 
 *  This program is free software under the terms of the GPLv3, see LICENCSE.txt
 *
 *           v_pos
 *              V
 *              |
 *        .-----+---+-----------------------------.
 *        |         |                             |
 *        |         |                             |
 *        |         |                             |
 *        Z         |8                            |
 *     R1 Z     .---------.                       |
 *        |    7|  Vcc    |                       |
 *        +-----|Discharge|                       |
 *        |     |         |                       |
 *        Z     |   555   |3                      |
 *     R2 Z     |      Out|---> Output Node       |
 *        |    6|         |                       |
 *        +-----|Threshold|                       | 
 *        |     |         |                       |
 *        +-----|Trigger  |                       |
 *        |    2|         |---< Control Voltage   |
 *        |     |  Reset  |5                      |
 *        |     '---------'                       |
 *       ---        4|                            |
 *     C ---         +----------------------------'
 *        |          |
 *        |          ^
 *       gnd       Reset
 * 
 *     Drawing based on a drawing from MAME discrete
 *
 ********************************************************************************/

module astable_555_vco#(
    parameter CLOCK_RATE = 50000000,
    parameter SAMPLE_RATE = 48000,
    parameter VCC = 12,
    parameter R1 = 47000,
    parameter R2 = 27000,
    parameter C_18_SHIFTED = 8651 // 33 nanofarad
) (
    input clk,
    input audio_clk_en,
    input[15:0] v_control,
    output reg[15:0] out
);
    localparam ln2_16_SHIFTED = 45426;
    localparam C_R2_ln2 = C_18_SHIFTED * R2 * ln2_16_SHIFTED >>> 34;
    localparam C_R1_R2_2_SHIFTED = C_18_SHIFTED * (R1 + R2) * ln2_16_SHIFTED >>> 32;

    wire[15:0] ln_vc_vcc_vc_16_shifted;
    
    natural_log natlog(
        1 - (v_control/((VCC <<< 1) - v_control)),
        clk,
        ln_vc_vcc_vc_16_shifted
    );

    reg[31:0] WAVE_LENGTH;
    assign WAVE_LENGTH = ((C_R1_R2_2_SHIFTED * ln_vc_vcc_vc_16_shifted) >>> 18) + C_R2_ln2;
   
    reg[30:0] HALF_WAVE_LENGTH = 0;
    assign HALF_WAVE_LENGTH = WAVE_LENGTH >>> 1;


    reg[31:0] wave_length_counter = 0;

    always @(posedge clk) begin
        if(wave_length_counter < WAVE_LENGTH)begin
           wave_length_counter <= wave_length_counter + 1;
        end else begin 
            wave_length_counter <= 0;
        end

        if(audio_clk_en)begin
            out <= wave_length_counter < HALF_WAVE_LENGTH;
        end
    end
endmodule