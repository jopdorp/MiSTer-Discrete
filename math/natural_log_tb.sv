/********************************************************************************\
 * 
 *  MiSTer Discrete math Log2highacc test bench
 *
 *  Copyright 2022 by Jegor van Opdorp. 
 *  This program is free software under the terms of the GPLv3, see LICENCSE.txt
 *
 ********************************************************************************/
module natural_log_tb();

    reg clk = 1;
    reg[23:0] in;
    wire[11:0] out;
    natural_log log (
        .clk(clk),
        .in_8_shifted(in),
        .I_RSTn(1'b1),
        .out_8_shifted(out)
    );

    initial begin
        #1 in = 256; 
        #1 clk = 0;
        #1 clk = 1;
        #1 clk = 0;
        #1 clk = 1;
        #1 clk = 0;
        #1 clk = 1;
        #1 clk = 0;
        #1 clk = 1;
        #1 $display("%h", out);
        assert (out == 4) else begin
            $display("wrong");
        end
        #1 clk = 0;
        #1 clk = 1;
        assert (out == 4) else begin
            $display("wrong");
        end
        #1 clk = 0;
        #1 clk = 1;
        assert (out == 4) else begin
            $display("wrong");
        end
        #1 clk = 0;
        #1 clk = 1;
        assert (out == 4) else begin
            $display("wrong");
        end
        #1 clk = 0;
        #1 clk = 1;
        assert (out == 4) else begin
            $display("wrong");
        end
        #1 in = 'h1000; 
        #1 clk = 0;
        #1 clk = 1;
        #1 clk = 0;
        #1 clk = 1;
        #1 clk = 0;
        #1 clk = 1;
        #1 clk = 0;
        #1 clk = 1;
        #1 $display("%h", out);
        assert (out == 'h2c5) else begin
             $display("wrong");
        end
    end
    
endmodule