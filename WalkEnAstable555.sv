// Model generated on 2023-12-30 11:43:34.443002

`include "svreal.sv"
`include "msdsl.sv"

`default_nettype none

`define RST_MSDSL I_RSTn
`define CLK_MSDSL clk

/* verilator lint_off LITENDIAN */
/* verilator lint_off REALCVT */
module WalkEnAstable555 #(
    `DECL_REAL(walk_en),
    `DECL_REAL(square_wave),
    `DECL_REAL(vcc),
    `DECL_REAL(v_control)
) (
    input clk,
    input I_RSTn,
    `INPUT_REAL(walk_en),
    `INPUT_REAL(square_wave),
    `INPUT_REAL(vcc),
    `OUTPUT_REAL(v_control)
);
    import math_pkg::*;
    // Declaring internal variables.
    `MAKE_REAL(tmp_circ_4, `RANGE_PARAM_REAL(v_control));
    // Assign signal: tmp_circ_4
    `MUL_CONST_REAL(0.9988949512946891, tmp_circ_4, tmp0);
    `MUL_CONST_REAL(0.00021549311726031938, square_wave, tmp1);
    `MUL_CONST_REAL(0.0006309638473382152, vcc, tmp2);
    `MUL_CONST_REAL(0.0002585917407123833, walk_en, tmp3);
    `ADD_REAL(tmp0, tmp1, tmp4);
    `ADD_REAL(tmp2, tmp3, tmp5);
    `ADD_REAL(tmp4, tmp5, tmp6);
    `DFF_INTO_REAL(tmp6, tmp_circ_4, `RST_MSDSL, `CLK_MSDSL, 1'b1, 0);
    // Assign signal: v_control
    `ASSIGN_REAL(tmp_circ_4, v_control);
endmodule

`default_nettype wire
