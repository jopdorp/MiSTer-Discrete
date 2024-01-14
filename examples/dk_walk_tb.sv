/********************************************************************************\
 * 
 *  MiSTer Discrete dk walk test bench
 *
 *  Copyright 2022 by Jegor van Opdorp. 
 *  This program is free software under the terms of the GPLv3, see LICENCSE.txt
 *
 ********************************************************************************/
// Define macro for clock CLK_MSDSL
`define CLK_MSDSL 1'b1
// Define macro for RST_MSDSL
`define RST_MSDSL 1'b1
`include "svreal.sv"
`include "msdsl.sv"

module dk_walk_tb();
    import math_pkg::*;

    reg clk = 0;
    reg audio_clk_en = 0;
    reg walk_en = 0;
    reg I_RSTn = 1;
    wire signed[15:0] walk_out;
    wire[15:0] O_SOUND_DAT;
    localparam OVERSAMPLE = 2;
    localparam CLOCK_RATE = 2 * 48000 * OVERSAMPLE;
    localparam SAMPLE_RATE = 48000 * OVERSAMPLE;
    localparam CYCLES_PER_SAMPLE = CLOCK_RATE / SAMPLE_RATE * OVERSAMPLE;
    localparam steps = CYCLES_PER_SAMPLE * 1400;
    localparam HIGH_TIME = 1;
    localparam LOW_TIME = 6;

    assign CLK_MSDSL = clk;
    assign RST_MSDSL = I_RSTn;

    dk_walk #(.CLOCK_RATE(CLOCK_RATE),.SAMPLE_RATE(SAMPLE_RATE)) walk (
        .clk(clk),
        .I_RSTn(I_RSTn),
        .audio_clk_en(audio_clk_en),
        .walk_en(~walk_en),
        .out(walk_out)
    );

    assign O_SOUND_DAT = (walk_out) + 2**15;

    int file, i;

    task run_times(int  times);
        for(int i = 0; i < times; i++) begin
            #(i*(CYCLES_PER_SAMPLE));
            #1 clk = 0;
            #1 clk = 1;
            #1;

            if((i%CYCLES_PER_SAMPLE) == CYCLES_PER_SAMPLE-2)begin
                audio_clk_en = 1;                
            end else if(i%CYCLES_PER_SAMPLE == CYCLES_PER_SAMPLE-1) begin
                audio_clk_en = 0;
                $fwrite(file,"%d\n", O_SOUND_DAT);
            end

        end
    endtask

    task walk_times(int times);
        for(int i = 0; i < times; i++) begin
            #1 walk_en = 1;
            #1 run_times(steps * HIGH_TIME);
            #1 walk_en = 0;
            #1 run_times(steps * LOW_TIME);
        end
    endtask

    initial begin
        file = $fopen("dk_walk.csv","wb");
        #1 clk = 0;
        #1 clk = 1;
        #1 I_RSTn = 0;
        #1 clk = 0;
        #1 clk = 1;
        #1 I_RSTn = 1;
        #1 clk = 0;
        #1 clk = 1;
        walk_times(8);
        $fclose(file);
    end


    
endmodule