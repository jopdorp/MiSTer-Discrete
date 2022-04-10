/********************************************************************************\
 * 
 *  MiSTer Discrete natural log core
 *
 *  Copyright 2022 by Jegor van Opdorp. 
 *  This program is free software under the terms of the GPLv3, see LICENCSE.txt
 *
 ********************************************************************************/
module natural_log(input clk, input x, output reg[15:0] out_4_shifted);
    
    localparam RATIO_16_SHIFTED = 45426; // 1 / log2(e)

    reg[11:0] log2_x = 0;
    Log2highacc log2(
        x,
        clk,
        log2_x
    );

    always @(posedge clk) begin
       out <= RATIO_16_SHIFTED * log2_x >>> 16; 
    end

endmodule