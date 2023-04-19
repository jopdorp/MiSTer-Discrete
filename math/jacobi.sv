/********************************************************************************\
 * 
 *  MiSTer Discrete jacobi iterative method core
 *
 *  Copyright 2022 by Jegor van Opdorp. 
 *  This program is free software under the terms of the GPLv3, see LICENCSE.txt
 *
 ********************************************************************************/
module jacobi#(
    parameter SIZE=3,
    parameter PRECISION=16,
    parameter POINT=8,
    parameter CLOCK_SPEED=10000000,
    parameter SAMPLE_RATE=48000
)(
    input clk, 
    input I_RSTn,
    input signed[PRECISION+POINT:0] A[SIZE-1:0][SIZE-1:0],
    input signed[PRECISION+POINT:0] b[SIZE-1:0],
    output reg signed[PRECISION+POINT:0] x[SIZE-1:0]
);
    reg [3:0] iteration = 0;
    reg[1:0] step = 0;
    
    always_ff @(posedge clk) begin
        if(~I_RSTn)begin
            x[0] <= 0 <<< POINT;
            x[1] <= 0 <<< POINT;
            x[2] <= 0 <<< POINT;
            step <= 0;
            iteration <= 0;
        end else begin
            if(step == 3)begin
                iteration <= iteration + 1;
            end
            step <= step + 1;
        end
    end


    genvar i, j;
    generate
        for (i = 0; i < SIZE; i++) begin
            reg signed[PRECISION+POINT:0] s[SIZE-1:0];
            wire signed[PRECISION+POINT:0] sum_s[SIZE:0];

            for (j = 0; j < SIZE; j++) begin
                always_ff @(posedge clk) begin
                    case (step)
                        0 : begin 
                            s[j] <= 0;
                        end
                        1 : begin if (j != i) begin
                            s[j] <= (A[i][j] * x[j]) >>> POINT;
                        end end
                        2 : begin
                            // let sum_s resolve.
                        end
                    endcase
                end
                assign sum_s[0] = 0;
                assign sum_s[j+1] = sum_s[j] + s[j];
            end

            

            always_ff @(posedge clk) begin
                case (step)
                    3 : begin
                        x[i] <= ((b[i] - sum_s[SIZE]) <<<  POINT) / A[i][i];
                    end
                endcase
            end
        end
    endgenerate
endmodule