// Model generated on 2024-02-12 17:58:09.091850




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
    wire signed[0:18] tmp0;
    wire signed[0:18] tmp1;
    wire signed[0:18] tmp2;
    wire signed[0:18] tmp3;
    wire signed[0:18] tmp4;
    wire signed[0:18] tmp5;
    wire signed[0:18] tmp6;

    wire signed[0:18] walk_en_denormalized; // Point 14 
    assign walk_en_denormalized = { { 5{ walk_en[15]}}, walk_en } * 5 >> 0;
    wire signed[0:18] square_wave_denormalized; // Point 14 
    assign square_wave_denormalized = { { 5{ square_wave[15]}}, square_wave } * 5 >> 0;
    localparam signed[0:18] vcc_denormalized = 5 << 14; // Point: 14
    reg signed[0:18] tmp_circ_4 = 0;  // Point: 12 

    // Assign signal: tmp_circ_4
    assign tmp0 = ({ { 14{ tmp_circ_4[18]}}, tmp_circ_4 } * 16366) >> 14;  // Point: 12;
    assign tmp1 = ({ { 14{ walk_en_denormalized[18]}}, walk_en_denormalized } * 8677) >> 14;  // Point: 25;
    assign tmp2 = ({ { 14{ square_wave_denormalized[18]}}, square_wave_denormalized } * 14462) >> 14;  // Point: 26;
    assign tmp3 = ({ { 14{ vcc_denormalized[18]}}, vcc_denormalized } * 10586) >> 14;  // Point: 24;
    assign tmp4 = ({ tmp0, { 13{'0} } }) + tmp1; // Point: 25;
    assign tmp5 = tmp2 + ({ tmp3, { 2{'0} } }); // Point: 26;
    assign tmp6 = ({ tmp4, { 1{'0} } }) + tmp5; // Point: 26;
    always @(posedge clk) begin
        if (~I_RSTn) begin
            tmp_circ_4 <= 19'b0;
        end else if (audio_clk_en) begin
            tmp_circ_4 <= tmp6 >> 14;
        end
    end
    // Assign signal: v_control
    assign v_control = ({ { 14{ tmp_circ_4[18]}}, tmp_circ_4 } * 3276) >> 12;  // Scale factor: 3276, Point: 14;
endmodule

