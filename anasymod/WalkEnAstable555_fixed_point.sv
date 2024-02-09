// Model generated on 2024-02-08 22:37:14.201017

`timescale 1ns/1ps

`include "svreal.sv"
`include "msdsl.sv"

`default_nettype none

module WalkEnAstable555 #(
    `DECL_REAL(walk_en),
    `DECL_REAL(square_wave),
    `DECL_REAL(vcc),
    `DECL_REAL(v_control)
) (
    `INPUT_REAL(walk_en),
    `INPUT_REAL(square_wave),
    `INPUT_REAL(vcc),
    `OUTPUT_REAL(v_control)
);
    // Declaring internal variables.
    `MAKE_REAL(tmp_circ_4, `RANGE_PARAM_REAL(v_control));
    // Assign signal: tmp_circ_4
    tmp0 = tmp_circ_4 * 4091;  // Point: 12, Sign: +;
    tmp1 = square_wave * 3615;  // Point: 24, Sign: +;
    tmp2 = vcc * 2646;  // Point: 22, Sign: +;
    tmp3 = walk_en * 2169;  // Point: 23, Sign: +;
    tmp4 = (tmp0 << 12) + tmp1;;
    tmp5 = (tmp2 << 1) + tmp3;;
    tmp6 = tmp4 + tmp5;;
    `DFF_INTO_REAL(tmp6, tmp_circ_4, `RST_MSDSL, `CLK_MSDSL, 1'b1, 0);
    // Assign signal: v_control
    v_control = (tmp_circ_4 * 2560) >> 23;  // Scale factor: 0.0003051944088384301, Point: 23, Sign: +;
endmodule

`default_nettype wire
