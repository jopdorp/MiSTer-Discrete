/********************************************************************************\
 * 
 *  MiSTer Discrete resistor_capacitor_low_pass_filter test bench
 *
 *  Copyright 2022 by Jegor van Opdorp. 
 *  This program is free software under the terms of the GPLv3, see LICENCSE.txt
 *
 ********************************************************************************/
module resistor_capacitor_low_pass_filter_tb();

    reg clk = 0;
    reg audio_clk_en = 0;
    reg[15:0] v_control = 0;
    wire[15:0] out;
    wire[15:0] filtered_out;
    localparam CLOCK_RATE = 1000000;
    localparam SAMPLE_RATE = 48000;
    localparam CYCLES_PER_SAMPLE = CLOCK_RATE / SAMPLE_RATE;

    astable_555_vco #(.CLOCK_RATE(CLOCK_RATE)) osc (
        .clk(clk),
        .audio_clk_en(audio_clk_en),
        .v_control(v_control),
        .out(out)
    );

    resistor_capacitor_low_pass_filter #(.CLOCK_RATE(CLOCK_RATE)) filter (
        clk,
        audio_clk_en,
        out,
        filtered_out
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
                $fwrite(file,"%d\n", filtered_out);
            end

        end
    endtask


    localparam steps = CYCLES_PER_SAMPLE * 3000;
    initial begin
        file = $fopen("resistor_capacitor_low_pass_filter.csv","wb");
        #1 v_control = 32767;
        #1 run_times(steps);
        #1 v_control = 30000;
        #1 run_times(steps);
        #1 v_control = 25000;
        #1 run_times(steps);
        #1 v_control = 20000;
        #1 run_times(steps);
        #1 v_control = 15000;
        #1 run_times(steps);
        #1 v_control = 10000;
        #1 run_times(steps);
        #1 v_control = 5000;
        #1 run_times(steps);
        #1 v_control = 2500;
        #1 run_times(steps);
        #1 v_control = 1000;
        #1 run_times(steps);
        #1 v_control = 0;
        #1 run_times(steps);
        #1 v_control = -1000;
        #1 run_times(steps);
        $fclose(file);
    end


    
endmodule