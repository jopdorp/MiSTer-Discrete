/********************************************************************************\
 * 
 *  MiSTer Discrete jacobi iterative method test bench
 *
 *  Copyright 2022 by Jegor van Opdorp. 
 *  This program is free software under the terms of the GPLv3, see LICENCSE.txt
 *
 ********************************************************************************/
module qdiv_tb();
	reg clk = 0;
	reg start = 0;
    
	reg [31:0] a = 12;
	reg [31:0] b = 3;
 
	// Outputs
	reg [31:0] out;
    reg complete;
    localparam POINT = 8;
    localparam PRECISION = 24;
	qdiv #(.Q(POINT),.N(PRECISION+POINT))	uut (a <<< POINT, b <<< POINT, start, clk, out, complete);

    task run_times(int  times);
        for(int i = 0; i < times; i++) begin
            #1 clk = 0;
            #1 clk = 1;
            #1 $display(complete);
        end
        #1 $display("%d", out >>> POINT);
    endtask

    initial begin
        #1 clk = 0;
        #1 clk = 1;
        #1 start = 1;
        run_times(POINT+POINT+PRECISION);
        assert (out >>> POINT == 4) begin
            #1 $display("correct!");
        end else begin
            #1 $display("wrong");
        end
    end
endmodule
