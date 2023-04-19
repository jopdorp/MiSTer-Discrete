/********************************************************************************\
 * 
 *  MiSTer Discrete math Log2highacc test bench
 *
 *  Copyright 2022 by Jegor van Opdorp. 
 *  This program is free software under the terms of the GPLv3, see LICENCSE.txt
 *
 ********************************************************************************/
module invertor_square_wave_oscilator_tb();
    localparam SIZE = 3;

    reg[15:0] in[SIZE-1:0][SIZE:0];
    reg clk = 1;

    wire[15:0] out[SIZE-1:0];

    gaussian_elimination #(
        .SIZE(SIZE)
    ) gauss (
        .clk(clk),
        .I_RSTn(1'b1),
        .in(in),
        .out(out)
    );

    initial begin
        // #1 in = 256; 
        #1 clk = 0;
        #1 clk = 1;
        #1 clk = 0;
        #1 clk = 1;
        #1 clk = 0;
        #1 clk = 1;
        #1 clk = 0;
        #1 clk = 1;
        #1 $display("%h", out);
        assert (out[0] == 4) else begin
            $display("wrong");
        end
    end
    
endmodule