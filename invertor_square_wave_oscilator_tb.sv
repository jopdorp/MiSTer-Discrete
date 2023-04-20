/********************************************************************************\
 * 
 *  MiSTer Discrete invertor square wave oscilator test bench
 *
 *  Copyright 2022 by Jegor van Opdorp. 
 *  This program is free software under the terms of the GPLv3, see LICENCSE.txt
 *
 ********************************************************************************/
module invertor_square_wave_oscilator_tb();

    reg clk = 0;
    reg audio_clk_en = 1;
    wire signed[15:0] out;
    invertor_square_wave_oscilator #(.CLOCK_RATE(48000)) osc (
        clk,
        1'b1,
        audio_clk_en,
        out
    );

    int file, i;

    task run_times(int times);
        for(int i = 0; i < times; i++) begin
            #(i*(times/4));
            #1 clk = 1;
            #1 clk = 0;
            #1;
            $fwrite(file,"%d\n", out);
        end
    endtask

    initial begin
        file = $fopen("invertor_square_wave_oscilator.csv","wb");
        $fwrite(file,"%s\n", "value");
        #1 run_times(480000);
        #1;
        $fclose(file);
    end
    
endmodule