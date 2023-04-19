/********************************************************************************\
 * 
 *  MiSTer Discrete gaussian elimination core
 *
 *  Copyright 2022 by Jegor van Opdorp. 
 *  This program is free software under the terms of the GPLv3, see LICENCSE.txt
 *
 ********************************************************************************/
module gaussian_elimination#(
    parameter SIZE=1,
    parameter CLOCK_SPEED=10000000,
    parameter SAMPLE_RATE=48000
)(input clk, input I_RSTn, input[15:0] in[SIZE-1:0][SIZE:0], output reg[15:0] out[SIZE-1:0]);
    localparam m = SIZE;
    localparam n = SIZE + 1;
    localparam CYCLES_IN_SAMPLE = CLOCK_SPEED / SAMPLE_RATE;

    shortint step = 0;
    reg[15:0] intermediate_in[SIZE-1:0][SIZE:0];
    genvar o, p;
    generate
        for(o = 0; o < SIZE-1; o = o + 1) begin
            for(p = 0; p < SIZE; p = p + 1) begin
                always_ff @(posedge clk) begin
                    if (step == 0) begin
                        intermediate_in[o][p] <= in[o][p];
                    end
                end
            end
        end
    endgenerate

    always_ff @(posedge clk) begin
        if (step == 0) begin
            step <= 1;
        end
    end

    genvar k, i, j;
    generate
        for(k = 0; k < m; k = k + 1) begin
            // pivots = [abs(A[i][k]) for i in range(k, m)]
            reg[15:0] pivots[m-k:0];
            

            for(i = k + 1; i < m; i = i + 1) begin
                reg[15:0] f;
                always_ff @(posedge clk) begin
                    if (step == 1) begin
                        pivots[i] <= in[i][k][15] ? -in[i][k] : in[i][k];
                        f <= in[i][k] / in[k][k];
                    end
                end

                for(j = k + 1; j < n; j = j + 1)begin
                    always_ff @(posedge clk) begin
                        if (step == 1) begin
                            intermediate_in[i][j] <= intermediate_in[i][j] - (intermediate_in[k][j] * f);
                        end
                    end
                end
            end

        end

//             // i_max = pivots.find_first_index with (item == pivots.max());


        // end
    endgenerate

//     reg[15:0] i_max = 0;
//     always_ff @(posedge clk)begin
//         if(step == 0)begin
//             step <= 1;
//         end

//     end

endmodule

// module divider(
//     input clk,
//     input[15:0] in,
//     input[15:0] divisor,
//     output reg[15:0] out
// );
//     always_ff @( posedge clk) begin
//         out <= in / divisor;
//     end
// endmodule