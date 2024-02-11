// Model generated on 2024-02-08 22:37:14.201017

`timescale 1ns/1ps

`include "svreal.sv"
`include "msdsl.sv"

`default_nettype none

module WalkEnAstable555 
( 
    input reg[0:15] walk_en,
    input reg[0:15] square_wave,
    input reg[0:15] vcc,
    output reg[0:15] v_control
);
    // Declaring internal variables.
    reg[0:16] tmp0;
    reg[0:26] tmp1;
    reg[0:24] tmp2;
    reg[0:25] tmp3;
    reg[0:26] tmp4;
    reg[0:25] tmp5;
    reg[0:26] tmp6;

    wire[0:13] walk_en_denormalized; // Point 10 
    assign walk_en_denormalized = walk_en * 5 >> 4;
    wire[0:13] square_wave_denormalized; // Point 10 
    assign square_wave_denormalized = square_wave * 5 >> 4;
    wire[0:13] vcc_denormalized; // Point 10 
    assign vcc_denormalized = vcc * 5 >> 4;

    reg [0:13] tmp_circ_4;  // Point: 12 

    // Assign signal: tmp_circ_4
    tmp0 = (tmp_circ_4 * 1023) >> 10;  // Point: 12;
    tmp1 = (square_wave_denormalized * 904) >> 10;  // Point: 22;
    tmp2 = (vcc_denormalized * 662) >> 10;  // Point: 20;
    tmp3 = (walk_en_denormalized * 542) >> 10;  // Point: 21;
    tmp4 = (tmp0 << 10) + tmp1; // Point: 22;
    tmp5 = (tmp2 << 1) + tmp3; // Point: 21;
    tmp6 = tmp4 + (tmp5 << 1); // Point: 22;
    always @(posedge `CLK_MSDSL) begin
        if (`RST_MSDSL) begin
            (tmp_circ_4 << 10) <= 16'b0;
        end else begin
            (tmp_circ_4 << 10) <= (tmp_circ_4 << 10) - tmp6;  // Point: 22
        end
    end
    // Assign signal: v_control
    v_control = (tmp_circ_4 * 3276.6) >> 12;  // Scale factor: 3276.6, Point: 14;
endmodule

`default_nettype wire
