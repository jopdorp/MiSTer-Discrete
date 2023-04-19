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
    parameter ITERATIONS=10,
    parameter PRECISION=16,
    parameter POINT=8,
    parameter CLOCK_SPEED=10000000,
    parameter SAMPLE_RATE=48000
)(
    input clk, 
    input I_RSTn,
    input signed[PRECISION+POINT-1:0] A[SIZE-1:0][SIZE-1:0],
    input signed[PRECISION+POINT-1:0] b[SIZE-1:0],
    output reg signed[PRECISION+POINT-1:0] x[SIZE-1:0],
    output ready
);
    // wire signed[PRECISION+POINT-1:0] D_reciprocal_temp[SIZE-1:0];
    // reg D_reciprocal_complete[SIZE-1:0];
    // genvar i, j;
    // generate
    //     for (i = 0; i < SIZE; i++) begin
    //         qdiv #(.Q(POINT),.N(PRECISION+POINT))	uut ({{(PRECISION+POINT-1){1'b0}},{1'b1}} <<< POINT, A[i][i], I_RSTn, clk, D_reciprocal_temp[i],D_reciprocal_complete[i]);
    //         always_ff @(posedge clk) begin
    //             if(D_reciprocal_complete[i])begin
    //                 x[i] <= D_reciprocal_temp[i];
    //             end
    //         end
    //     end
    // endgenerate


    reg [8:0] iteration = 0;
    reg[1:0] step = 0;
    wire signed[PRECISION+POINT-1:0] D_reciprocal_temp[SIZE-1:0];
    reg signed[PRECISION+POINT-1:0] D_reciprocal[SIZE-1:0];
    reg D_reciprocal_complete[SIZE-1:0];
    reg start[SIZE-1:0];

    always_ff @(posedge clk) begin
        if(~I_RSTn)begin
            step <= 0;
            iteration <= 0;
        end else if(~D_reciprocal_complete[0])begin
                step <= 0;
        end else begin
            step <= step + 1;
        end

        if(step == 3)begin
            iteration <= iteration + 1;
        end
    end




    genvar i, j;
    generate
        for (i = 0; i < SIZE; i++) begin
            reg signed[PRECISION+POINT-1:0] s[SIZE-1:0];
            wire signed[PRECISION+POINT-1:0] sum_s[SIZE:0];


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

            // qdiv #(.Q(POINT),.N(PRECISION+POINT))	uut ({{(PRECISION+POINT-1){1'b0}},{1'b1}} <<< POINT, A[i][i], start[i], clk, D_reciprocal_temp[i], D_reciprocal_complete[i]);

            always_ff @(posedge clk) begin
                if(~I_RSTn)begin
                    x[i] <= 0;
                    start[i] <= 1;
                end
                case (step)
                    0 : begin
                        if(D_reciprocal_complete[i])begin
                            D_reciprocal[i] <= D_reciprocal_temp[i];
                            start[i] <= 0;
                        end
                    end
                    3 : begin
                        // x[i] <= D_reciprocal[i];
                        // x[i] <= ((b[i] - sum_s[SIZE] <<< POINT) / A[i][i]);
                        x[i] <= ((b[i] - sum_s[SIZE]) * D_reciprocal[i]) >>> POINT;
                    end
                endcase
            end
        end
    endgenerate
endmodule
