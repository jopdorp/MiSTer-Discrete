/********************************************************************************\
 * 
 *  MiSTer Discrete gaussian elimination core
 *
 *  Copyright 2022 by Jegor van Opdorp. 
 *  This program is free software under the terms of the GPLv3, see LICENCSE.txt
 *
 ********************************************************************************/
module gaussian_elimination#(
    parameter SIZE=1
)(input clk, input I_RSTn, input[15:0] in[SIZE-1:0][SIZE:0], output reg[15:0] out[SIZE-1:0]);
    localparam m = SIZE;
    localparam n = SIZE + 1;

    genvar k, i;
    generate
        for(k = 0; k < m; k = k + 1)begin
            reg[15:0] pivots[m-k:0];
            for(i = k; i < m; i = i + 1)begin
                always_ff @( posedge clk) begin
                    pivots[i] <= in[i][k][15] ? -in[i][k] : in[i][k]; //take absolue value
                end
            end
        end
    endgenerate


endmodule

module divider(
    input clk,
    input[15:0] in,
    input[15:0] divisor,
    output reg[15:0] out
);
    always_ff @( posedge clk) begin
        out <= in / divisor;
    end
endmodule