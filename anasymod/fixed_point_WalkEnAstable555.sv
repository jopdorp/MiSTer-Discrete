// Model generated on 2024-02-11 21:27:39.942545

`timescale 1ns/1ps

`include "svreal.sv"
`include "msdsl.sv"

`default_nettype none

module WalkEnAstable555 
( 
    input signed wire[0:15] walk_en,
    input signed wire[0:15] square_wave,
    input signed wire[0:15] vcc,
    output signed wire[0:15] v_control
);
    // Declaring internal variables.
    signed wire[0:15] tmp0;
    signed wire[0:15] tmp1;
    signed wire[0:15] tmp2;
    signed wire[0:15] tmp3;
    signed wire[0:15] tmp4;
    signed wire[0:15] tmp5;
    signed wire[0:15] tmp6;

    signed wire[0:15] walk_en_denormalized; // Point 12 
    assign walk_en_denormalized = walk_en * 5 >> 2;
    signed wire[0:15] square_wave_denormalized; // Point 12 
    assign square_wave_denormalized = square_wave * 5 >> 2;
    signed wire[0:15] vcc_denormalized; // Point 12 
    assign vcc_denormalized = vcc * 5 >> 2;

    signed reg [0:15] tmp_circ_4;  // Point: 12 

    // Assign signal: tmp_circ_4
    assign tmp0 = ({ { 12{ tmp_circ_4[15]}}, tmp_circ_4 } * 4091) >> 12;  // Point: 12;
    assign tmp1 = ({ { 12{ vcc_denormalized[15]}}, vcc_denormalized } * 2646) >> 12;  // Point: 22;
    assign tmp2 = ({ { 12{ square_wave_denormalized[15]}}, square_wave_denormalized } * 3615) >> 12;  // Point: 24;
    assign tmp3 = ({ { 12{ walk_en_denormalized[15]}}, walk_en_denormalized } * 2169) >> 12;  // Point: 23;
    assign tmp4 = (tmp0 << 10) + tmp1; // Point: 22;
    assign tmp5 = tmp2 + (tmp3 << 1); // Point: 24;
    assign tmp6 = (tmp4 << 2) + tmp5; // Point: 24;
    always @(posedge `CLK_MSDSL) begin
        if (`RST_MSDSL) begin
            tmp_circ_4 <= 16'b0;
        end else begin
            tmp_circ_4 <= { { 12{ (tmp_circ_4 << 12)[15]}}, (tmp_circ_4 << 12) } - tmp6;  // Point: 24
        end
    end
    // Assign signal: v_control
    assign v_control = ({ { 12{ tmp_circ_4[15]}}, tmp_circ_4 } * 3276) >> 12;  // Scale factor: 3276, Point: 14;
endmodule

`default_nettype wire
