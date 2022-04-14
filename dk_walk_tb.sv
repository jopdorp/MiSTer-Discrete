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
    wire[15:0] walk_out;
    localparam CLOCK_RATE = 640000;
    localparam SAMPLE_RATE = 8000;
    localparam CYCLES_PER_SAMPLE = CLOCK_RATE / SAMPLE_RATE;

    dk_walk #(.CLOCK_RATE(CLOCK_RATE),.SAMPLE_RATE(8000)) walk (
        clk,
        audio_clk_en,
        walk_en,
        walk_out
    );

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
                // $fwrite(file,"%d\n", walk.square_osc_out);
                // $fwrite(file,"%d\n", walk.v_control);
                // $fwrite(file,"%d\n", walk.astable_555_out);
                // $fwrite(file,"%d\n", walk.walk_en_5volts);
                // $fwrite(file,"%d\n", walk.walk_en_filtered);
                // $fwrite(file,"%d\n", walk.walk_enveloped);
                $fwrite(file,"%d\n", walk_out);
            end

        end
    endtask


    localparam steps = CYCLES_PER_SAMPLE * 1000;
    initial begin
        file = $fopen("dk_walk.csv","wb");
        #1 walk_en = 1;
        #1 run_times(steps * 2);
        #1 walk_en = 0;
        #1 run_times(steps);
        #1 walk_en = 1;
        #1 run_times(steps * 2);
        #1 walk_en = 0;
        #1 run_times(steps);
        $fclose(file);
    end


    
endmodule