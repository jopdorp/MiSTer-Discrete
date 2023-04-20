/********************************************************************************\
 * 
 *  MiSTer Discrete dk walk test bench
 *
 *  Copyright 2022 by Jegor van Opdorp. 
 *  This program is free software under the terms of the GPLv3, see LICENCSE.txt
 *
 ********************************************************************************/
module dk_walk_tb();

    reg clk = 0;
    reg audio_clk_en = 0;
    reg walk_en = 0;
    reg I_RSTn = 1;
    wire signed[15:0] walk_out;
    wire[15:0] O_SOUND_DAT;
    localparam CLOCK_RATE = 32 * 48000;
    localparam SAMPLE_RATE = 96000;
    localparam OVERSAMPLE = 2;
    localparam CYCLES_PER_SAMPLE = CLOCK_RATE / SAMPLE_RATE * OVERSAMPLE;

    dk_walk #(.CLOCK_RATE(CLOCK_RATE),.SAMPLE_RATE(SAMPLE_RATE)) walk (
        .clk(clk),
        .I_RSTn(I_RSTn),
        .audio_clk_en(audio_clk_en),
        .walk_en(~walk_en),
        .out(walk_out)
    );

    // assign O_SOUND_DAT = sound_mix_low_passed;
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


    localparam steps = CYCLES_PER_SAMPLE * 1500;
    localparam HIGH_TIME = 1;
    localparam LOW_TIME = 6;
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
        #1 walk_en = 1;
        #1 run_times(steps * HIGH_TIME);
        #1 walk_en = 0;
        #1 run_times(steps * LOW_TIME);
        #1 walk_en = 1;
        #1 run_times(steps * HIGH_TIME);
        #1 walk_en = 0;
        #1 run_times(steps * LOW_TIME);
        #1 walk_en = 1;
        #1 run_times(steps * HIGH_TIME);
        #1 walk_en = 0;
        #1 run_times(steps * LOW_TIME);
        #1 walk_en = 1;
        #1 run_times(steps * HIGH_TIME);
        #1 walk_en = 0;
        #1 run_times(steps * LOW_TIME);
        #1 walk_en = 1;
        #1 run_times(steps * HIGH_TIME);
        #1 walk_en = 0;
        #1 run_times(steps * LOW_TIME);
        #1 walk_en = 1;
        #1 run_times(steps * HIGH_TIME);
        #1 walk_en = 0;
        #1 run_times(steps * LOW_TIME);
        $fclose(file);
    end


    
endmodule