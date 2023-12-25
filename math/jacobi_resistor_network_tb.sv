/********************************************************************************\
 * 
 *  MiSTer Discrete jacobi iterative method test bench
 *
 *  Copyright 2022 by Jegor van Opdorp. 
 *  This program is free software under the terms of the GPLv3, see LICENCSE.txt
 *
 *           R1    v1   R2    v2   R3    v3
 *      .---ZZZZ---.---ZZZZ---.---ZZZZ---.
 *      ▲ i1       ▼ i2       ▼ i3       ▼ i4
 *      |          |          |          |
 *   v0 |    ↻I1   Z   ↻I2    Z   ↻I3    Z
 *    _____     R4 Z       R5 Z       R6 Z
 *     ---         Z          Z          Z 
 *      |          |          |          |
 *      '----------+----------'----------'
 *                 |
 *                gnd 
 *
 *      [                                   
 *        [ R1+R4, -R4     , 0        ],     
 *        [ -R4  , R2+R3+R4, -R5      ],  * [I1,I2,I3] = [v0, 0, 0]
 *        [ 0    , -R5     , R3+R6+R5 ]
 *      ]
 *      
 *      i1 = I1
 *      i2 = I1 - I2
 *      i3 = I2 - I3
 *      i4 = I3
 *
 *      v1 = i2 * R4
 *      v2 = i3 * R5
 *      v3 = i4 * R6
 *
 ********************************************************************************/
module jacobi_tb();
    localparam SIZE = 3;
    reg clk = 1;
    reg not_reset = 1;
    reg start = 0;
    localparam POINT = 7;
    localparam PRECISION = 16;
    wire ready;

    wire signed[PRECISION+POINT-1:0] x[SIZE-1:0];

    reg signed[PRECISION+POINT-1:0] A[SIZE-1:0][SIZE-1:0];
    reg signed[PRECISION+POINT-1:0] b[SIZE-1:0];


    assign A[0][0] = 3 <<< POINT;
    assign A[0][1] = -1 <<< POINT;
    assign A[0][2] = 0 <<< POINT;

    assign A[1][0] = -1 <<< POINT;
    assign A[1][1] = 3 <<< POINT;
    assign A[1][2] = -1 <<< POINT;
    
    assign A[2][0] = 0 <<< POINT;
    assign A[2][1] = -1 <<< POINT;
    assign A[2][2] = 2 <<< POINT;

    assign b[0] = 52 <<< POINT;
    assign b[1] = 0 <<< POINT;
    assign b[2] = 0 <<< POINT;

    jacobi #(
        .SIZE(SIZE),
        .PRECISION(PRECISION),
        .POINT(POINT),
        .ITERATIONS(8)
    ) gauss (
        .clk(clk),
        .I_RSTn(not_reset),
        .start(start),
        .A(A),
        .b(b),
        .x(x),
        .ready(ready)
    );

    task run_times;
        while(~ready) begin
            #1 clk = 0;
            #1;
            #1 clk = 1;
            #1;
        end
        $display("%d", counter);
        for(int i = 0; i < SIZE; i ++)begin
            #1 $display("%d", x[i] >>> POINT);
        end
    endtask

    int counter = 0;

    always_ff @(posedge clk)begin
        counter++;
    end

    initial begin
        #1 not_reset = 0;
        #1 clk = 0;
        #1 clk = 1;
        #1 not_reset = 1;
        #1 clk = 0;
        #1 clk = 1;
        #1 start = 1;
        #1 counter = 0;
        #1 clk = 0;
        #1 clk = 1;
        #1 start = 0;
        #1;
        run_times();
        assert ((x[0] >>> POINT) == 19 && (x[1] >>> POINT) == 7 && (x[2] >>> POINT) == 3) begin
            #1 $display("correct!");
        end else begin
            #1 $display("wrong");
        end
    end
    
endmodule