// Model generated on 2024-02-08 22:37:14.201017

`timescale 1ns/1ps

`include "svreal.sv"
`include "msdsl.sv"

`default_nettype none

module WalkEnAstable555 
( 
    reg [0:15] walk_en 
    reg [0:15] square_wave 
    reg [0:15] vcc 
    `OUTPUT_REAL(v_control)
);
    // Declaring internal variables.
    reg[0:16] tmp0;
    reg[0:17] tmp1;
    reg[0:18] tmp2;
    reg[0:19] tmp3;
    reg[0:20] tmp4;
    reg[0:21] tmp5;
    reg[0:22] tmp6;

    wire[0:16] walk_en_denormalized; // Point 12 
    assign walk_en_denormalized = walk_en * 5 >> 2;
    wire[0:16] square_wave_denormalized; // Point 12 
    assign square_wave_denormalized = square_wave * 5 >> 2;
    wire[0:16] vcc_denormalized; // Point 12 
    assign vcc_denormalized = vcc * 5 >> 2;

    reg [0:16] tmp_circ_4;  // Point: 12 

    // Assign signal: tmp_circ_4
    tmp0 = (tmp_circ_4 * 4091) >> 12;  // Point: 12;
    tmp1 = (square_wave_denormalized * 3615) >> 12;  // Point: 24;
    tmp2 = (vcc_denormalized * 2646) >> 12;  // Point: 22;
    tmp3 = (walk_en_denormalized * 2169) >> 12;  // Point: 23;
    tmp4 = (tmp0 << 12) + tmp1; // Point: 24;
    tmp5 = (tmp2 << 1) + tmp3; // Point: 23;
    tmp6 = tmp4 + tmp5; // Point: 0;
    `DFF_INTO_REAL(tmp6, tmp_circ_4, `RST_MSDSL, `CLK_MSDSL, 1'b1, 0);
    // Assign signal: v_control
    v_control = (tmp_circ_4 * 3276.6) >> 12;  // Scale factor: 3276.6, Point: 14;
endmodule

`default_nettype wire
