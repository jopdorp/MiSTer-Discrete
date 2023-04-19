/********************************************************************************\
 * 
 *  MiSTer Discrete jacobi iterative method test bench
 *
 *  Copyright 2022 by Jegor van Opdorp. 
 *  This program is free software under the terms of the GPLv3, see LICENCSE.txt
 *
 ********************************************************************************/
module jacobi_tb();
    localparam SIZE = 3;
    reg clk = 1;
    reg not_reset = 1;
    localparam POINT = 8;
    localparam PRECISION = 16;

    wire signed[PRECISION+POINT:0] x[SIZE-1:0];

    reg signed[PRECISION+POINT:0] A[SIZE-1:0][SIZE-1:0];
    reg signed[PRECISION+POINT:0] b[SIZE-1:0];


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
        .POINT(POINT)
    ) gauss (
        .clk(clk),
        .I_RSTn(not_reset),
        .A(A),
        .b(b),
        .x(x)
    );


    task run_times(int  times);
        for(int i = 0; i < times; i++) begin
            #1 clk = 0;
            #1 clk = 1;
            #1;
        end
        for(int i = 0; i < SIZE; i ++)begin
            #1 $display("%d", x[i] >>> POINT);
        end

    endtask

    initial begin
        #1 clk = 0;
        #1 clk = 1;
        #1 not_reset = 0;
        #1 clk = 0;
        #1 clk = 1;
        #1 not_reset = 1;
        #1;
        run_times(4);
        run_times(8);
        run_times(16);
        assert ((x[0] >>> POINT) == 19 && (x[1] >>> POINT) == 7 && (x[2] >>> POINT) == 3) begin
            #1 $display("correct!");
        end else begin
            #1 $display("wrong");
        end
    end
    
endmodule