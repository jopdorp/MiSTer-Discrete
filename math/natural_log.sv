/********************************************************************************\
 * 
 *  MiSTer Discrete natural log core
 *
 *  Copyright 2022 by Jegor van Opdorp. 
 *  This program is free software under the terms of the GPLv3, see LICENCSE.txt
 *
 ********************************************************************************/
`ifndef Log2highacc
`define Log2highacc
`include "Log2highacc.sv"
`endif
module natural_log(input clk, input[23:0] in_8_shifted, output reg[15:0] out_8_shifted = 0);
    
    localparam RATIO_16_SHIFTED = 45426; // 1 / log2(e)

    wire[11:0] log2_x;
    
    Log2highacc log2(
        .DIN_8_shifted(in_8_shifted),
        .clk(clk),
        .DOUT_8_shifted(log2_x)
    );

    always_ff @( posedge clk ) begin : blockName
        if(log2_x)begin
            out_8_shifted <= RATIO_16_SHIFTED * log2_x >>> 16; 
        end
    end

endmodule