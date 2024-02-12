// Model generated on 2024-02-12 17:48:41.826958




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
    wire signed[0:16] tmp0;
    wire signed[0:16] tmp1;
    wire signed[0:16] tmp2;
    wire signed[0:16] tmp3;
    wire signed[0:16] tmp4;
    wire signed[0:16] tmp5;
    wire signed[0:16] tmp6;

    wire signed[0:16] walk_en_denormalized; // Point 12 
    assign walk_en_denormalized = { { 5{ walk_en[15]}}, walk_en } * 5 >> 2;
    wire signed[0:16] square_wave_denormalized; // Point 12 
    assign square_wave_denormalized = { { 5{ square_wave[15]}}, square_wave } * 5 >> 2;
    localparam signed[0:16] vcc_denormalized = 5 << 12; // Point: 12
    reg signed[0:16] tmp_circ_4 = 0;  // Point: 12 

    // Assign signal: tmp_circ_4
    assign tmp0 = ({ { 12{ tmp_circ_4[16]}}, tmp_circ_4 } * 4091) >> 12;  // Point: 12;
    assign tmp1 = ({ { 12{ walk_en_denormalized[16]}}, walk_en_denormalized } * 2169) >> 12;  // Point: 23;
    assign tmp2 = ({ { 12{ vcc_denormalized[16]}}, vcc_denormalized } * 2646) >> 12;  // Point: 22;
    assign tmp3 = ({ { 12{ square_wave_denormalized[16]}}, square_wave_denormalized } * 3615) >> 12;  // Point: 24;
    assign tmp4 = ({ tmp0, { 11{'0} } }) + tmp1; // Point: 23;
    assign tmp5 = ({ tmp2, { 2{'0} } }) + tmp3; // Point: 24;
    assign tmp6 = ({ tmp4, { 1{'0} } }) + tmp5; // Point: 24;
    always @(posedge clk) begin
        if (~I_RSTn) begin
            tmp_circ_4 <= 17'b0;
        end else if (audio_clk_en) begin
            tmp_circ_4 <= tmp6 >> 12;
        end
    end
    // Assign signal: v_control
    assign v_control = ({ { 12{ tmp_circ_4[16]}}, tmp_circ_4 } * 3276) >> 12;  // Scale factor: 3276, Point: 14;
endmodule

