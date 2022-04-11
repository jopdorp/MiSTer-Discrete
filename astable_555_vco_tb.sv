/********************************************************************************\
 * 
 *  MiSTer Discrete astable 555 vco test bench
 *
 *  Copyright 2022 by Jegor van Opdorp. 
 *  This program is free software under the terms of the GPLv3, see LICENCSE.txt
 *
 ********************************************************************************/
module astable_555_vco_tb();

    reg clk = 0;
    reg audio_clk_en = 1;
    reg[15:0] v_control = 1 <<< 15;
    wire[15:0] out;

    astable_555_vco #(.CLOCK_RATE(48000)) osc (
        .clk(clk),
        .audio_clk_en(audio_clk_en),
        .v_control(v_control),
        .out(out)
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
        file = $fopen("astable_555_vco.csv","wb");
        $fwrite(file,"%s\n", "value");
        #1 run_times(12000);
        #1 v_control = 1 <<< 12;
        #1 run_times(12000);
        #1 v_control = 1 <<< 9;
        #1 run_times(12000);
        #1;
        $fclose(file);
    end
    
endmodule