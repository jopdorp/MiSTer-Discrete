/********************************************************************************\
 * 
 *  MiSTer Discrete resistor_capacitor_high_pass_filter test bench
 *
 *  Copyright 2022 by Jegor van Opdorp. 
 *  This program is free software under the terms of the GPLv3, see LICENCSE.txt
 *
 ********************************************************************************/
module resistor_capacitor_high_pass_filter_tb();

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

    resistor_capacitor_high_pass_filter #(.CLOCK_RATE(CLOCK_RATE)) filter (
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


    localparam steps = CYCLES_PER_SAMPLE * 1500;
    initial begin
        file = $fopen("resistor_capacitor_high_pass_filter.csv","wb");
        #1 v_control = 1 <<< 16 - 1;
        #1 run_times(steps);
        #1 v_control = (1 <<< 16) - (1 <<< 1);
        #1 run_times(steps);
        #1 v_control = (1 <<< 16) - (1 <<< 2);
        #1 run_times(steps);
        #1 v_control = (1 <<< 16) - (1 <<< 3);
        #1 run_times(steps);
        #1 v_control = (1 <<< 16) - (1 <<< 4);
        #1 run_times(steps);
        #1 v_control = (1 <<< 16) - (1 <<< 5);
        #1 run_times(steps);
        #1 v_control = (1 <<< 16) - (1 <<< 6);
        #1 run_times(steps);
        #1 v_control = (1 <<< 16) - (1 <<< 7);
        #1 run_times(steps);
        #1 v_control = (1 <<< 16) - (1 <<< 8);
        #1 run_times(steps);
        #1 v_control = (1 <<< 16) - (1 <<< 9);
        #1 run_times(steps);
        #1 v_control = (1 <<< 16) - (1 <<< 10);
        #1 run_times(steps);
        #1 v_control = (1 <<< 16) - (1 <<< 11);
        #1 run_times(steps);
        #1 v_control = (1 <<< 16) - (1 <<< 12);
        #1 run_times(steps);
        #1 v_control = (1 <<< 16) - (1 <<< 13);
        #1 run_times(steps);
        #1 v_control = 1 <<< 15;
        #1 run_times(steps);
        #1 v_control = 1 <<< 14;
        #1 run_times(steps);
        #1 v_control = 1 <<< 12;
        #1 run_times(steps);
        #1 v_control = 1 <<< 10;
        #1 run_times(steps);
        #1 v_control = 1 <<< 8;
        #1 run_times(steps);
        #1 v_control = 1 <<< 4;
        #1 run_times(steps);
        $fclose(file);
    end


    
endmodule