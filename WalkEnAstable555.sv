// Model generated on 2024-02-16 11:38:37.847568




module WalkEnAstable555 
( 
    input clk, 
    input audio_clk_en, 
    input I_RSTn, 
    input signed[0:15] walk_en,
    input signed[0:15] square_wave,
    output signed[0:15] v_control
);
    // Declaring internal variables.
    wire signed[0:28] tmp0;
    wire signed[0:28] tmp1;
    wire signed[0:28] tmp2;
    wire signed[0:28] tmp3;
    wire signed[0:28] tmp4;
    wire signed[0:28] tmp5;
    wire signed[0:28] tmp6;

    wire signed[0:16] walk_en_denormalized; // Point 12 
    assign walk_en_denormalized = walk_en * 5 >> 2;
    wire signed[0:16] square_wave_denormalized; // Point 12 
    assign square_wave_denormalized = square_wave * 5 >> 2;
    localparam signed[0:16] vcc_denormalized = 5 << 12; // Point: 12
    reg signed[0:40] tmp_circ_4 = 0;  // Point: 24 

    // Assign signal: tmp_circ_4
    assign tmp0 = tmp_circ_4 * 4091 >> 12;  // Point: 24;
    assign tmp1 = walk_en_denormalized * 2169 >> 12;  // Point: 23;
    assign tmp2 = vcc_denormalized * 2646 >> 12;  // Point: 22;
    assign tmp3 = square_wave_denormalized * 3615 >> 12;  // Point: 24;
    assign tmp4 = tmp0 + ({ tmp1, { 1{'0} } }); // Point: 24;
    assign tmp5 = ({ tmp2, { 2{'0} } }) + tmp3; // Point: 24;
    assign tmp6 = tmp4 + tmp5; // Point: 24;
    always @(posedge clk) begin
        if (~I_RSTn) begin
            tmp_circ_4 <= 17'b0;
        end else if (audio_clk_en) begin
            tmp_circ_4 <= tmp6 >> 0;
        end
    end
    // Assign signal: v_control
    assign v_control = tmp_circ_4 * 3276 >> 24;  // Scale factor: 3276, Point: 14;
endmodule

