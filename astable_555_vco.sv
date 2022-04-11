/********************************************************************************\
 * 
 *  MiSTer Discrete invertor square wave oscilator test bench
 *
 *  Copyright 2022 by Jegor van Opdorp. 
 *  This program is free software under the terms of the GPLv3, see LICENCSE.txt
 *
 *  Model taken from the equation on https://electronics.stackexchange.com/questions/101530/what-is-the-equation-for-the-555-timer-control-voltage
 *  
 *  wave_length = = C*(R1+R2)*ln(1-v_control/(2*VCC-v_control))+C*R2*ln(2)
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
`ifndef natural_log
`define natural_log
`include "math/natural_log.sv"
`endif

`ifndef invertor_square_wave_oscilator
`define invertor_square_wave_oscilator
`include "invertor_square_wave_oscilator.sv"
`endif

module astable_555_vco#(
    parameter CLOCK_RATE = 50000000,
    parameter SAMPLE_RATE = 48000,
    parameter R1 = 47000,
    parameter R2 = 27000,
    parameter C_18_SHIFTED = 8651 // 33 nanofarad
) (
    input clk,
    input audio_clk_en,
    input[23:0] v_control,
    output reg[15:0] out
);
    localparam longint VCC = 65536;
    localparam ln2_16_SHIFTED = 45426;
    localparam C_R2_ln2 = C_18_SHIFTED * R2 * ln2_16_SHIFTED >>> 34;
    localparam longint C_R1_R2_2_SHIFTED = C_18_SHIFTED * (R1 + R2) * ln2_16_SHIFTED >>> 32;

    wire[15:0] ln_vc_vcc_vc_8_shifted;
    wire[23:0] to_log_8_shifted;
    assign to_log_8_shifted = (1 <<< 8) - ((v_control <<< 8) / ((VCC * 2) - v_control)); //TODO how to translate v_control to be compatible with VCC
    
    natural_log natlog(
        .in_8_shifted(to_log_8_shifted),
        .clk(clk),
        .out_8_shifted(ln_vc_vcc_vc_8_shifted)
    );

    reg[31:0] WAVE_LENGTH;
    assign WAVE_LENGTH = ((C_R1_R2_2_SHIFTED * ln_vc_vcc_vc_8_shifted) >>> 10) + C_R2_ln2;
   
    wire[30:0] HALF_WAVE_LENGTH = 0;

    reg[31:0] wave_length_counter = 0;

    always @(posedge clk) begin
        if(wave_length_counter < WAVE_LENGTH)begin
           wave_length_counter <= wave_length_counter + 1;
        end else begin 
            wave_length_counter <= 0;
        end

        if(audio_clk_en)begin
            out <= (wave_length_counter < (WAVE_LENGTH >>> 1)) <<< 15;
        end
    end
endmodule