/********************************************************************************\
 * 
 *  MiSTer Discrete math Log2highacc test bench
 *
 *  Copyright 2022 by Jegor van Opdorp. 
 *  This program is free software under the terms of the GPLv3, see LICENCSE.txt
 *
 ********************************************************************************/
module Log2highacc_tb();

    reg clk = 1;
    reg[23:0] in;
    wire[11:0] out;
    Log2highacc log (
        .DIN_8_shifted(in),
        .clk(clk),
        .DOUT_8_shifted(out)
    );

    initial begin
        #1 in = 'h1000; 
        #1 clk = 0;
        #1 clk = 1;
        #1 $display("%h", out);
        #1 clk = 0;
        #1 clk = 1;
        #1 $display("%h", out);
        #1 clk = 0;
        #1 clk = 1;
        #1 $display("%h", out);
        assert (out == 'h400) else begin
             $display("wrong");
        end
    end
    
endmodule