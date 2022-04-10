/*********************************************************************\
 *  Simplified model of the below circuit.
 *  This model does not take the  transfer functions of the invertors 
 *  into account
 *
 *        |\        |\
 *        | \       | \
 *     +--|  >o--+--|-->o--+-------> out
 *     |  | /    |  | /    |
 *     |  |/     |  |/     |
 *     Z         Z         |
 *     Z         Z R1     --- C
 *     Z         Z        --- 
 *     |         |         |
 *     '---------+---------'
 *
 *********************************************************************/
module invertor_square_wave_oscilator_tb();

    reg clk = 0;
    reg audio_clk_en = 1;
    wire out;
    wire[15:0] audio_out;
    assign audio_out = out <<< 15;
    invertor_square_wave_oscilator #(.CLOCK_RATE(48000),.R1(430),.C_16_SHIFTED(65536)) osc (
        clk,
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
            $fwrite(file,"%d\n", audio_out);
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