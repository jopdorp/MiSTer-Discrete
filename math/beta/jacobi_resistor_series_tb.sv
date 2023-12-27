/********************************************************************************\
 * 
 *  MiSTer Discrete jacobi iterative method test bench
 *
 *  Copyright 2022 by Jegor van Opdorp. 
 *  This program is free software under the terms of the GPLv3, see LICENCSE.txt
 *
 *           R1    v1   
 *      .---ZZZZ---.
 *      |          |
 *      ▲ I_V0     |
 *   v0 |          Z
 *    _____     R4 Z
 *     ---         Z
 *      |          |
 *      '----------+
 *                 |
 *                gnd 
 *
 ********************************************************************************/
module jacobi_tb();
    localparam SIZE = 3;
    reg clk = 1;
    reg not_reset = 1;
    reg start = 0;
    localparam POINT = 16;
    localparam PRECISION = 32;
    wire ready;

    wire signed[PRECISION+POINT-1:0] x[SIZE-1:0];

    reg signed[PRECISION+POINT-1:0] A[SIZE-1:0][SIZE-1:0];
    reg signed[PRECISION+POINT-1:0] b[SIZE-1:0];

    localparam signed V0 = 12;
    localparam signed R1 = 100;
    localparam signed R2 = 100;
    
    assign A[0][0] = (1 <<< POINT) / R1;
    assign A[0][1] = (-1 <<< POINT ) / R1;
    assign A[0][2] = 1 <<< POINT;

    assign A[1][0] = (-1 <<< POINT) / R1;
    assign A[1][1] = (1 <<< POINT) / R2 + (1 <<< POINT) / R1;
    assign A[1][2] = 0;
    
    assign A[2][0] = 1 <<< POINT;
    assign A[2][1] = 0 <<< POINT;
    assign A[2][2] = 0 <<< POINT;

    assign b[0] = 0 <<< POINT;
    assign b[1] = 0 <<< POINT;
    assign b[2] = V0 <<< POINT;

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
        assert ((x[0] >>> POINT) == 12 && (x[1] >>> POINT) == 6 && (x[2] >>> POINT) == 0) begin
            #1 $display("correct!");
        end else begin
            #1 $display("x[0]%d, x[1]%d, x[2]%d",x[0] >>> POINT,x[1] >>> POINT,x[2] >>> POINT);
            #1 $display("wrong");
        end
    end
    
endmodule