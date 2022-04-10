module bonus_tb;

  logic clk;
  wire[15:0]  out;

  logic bonus_en = 0;

  bonus bonus(
   .clk(clk),
   .clk_48KHz_en('1),
   .bonus_en(bonus_en),
   .audio_out(out)
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
    file = $fopen("bonus.csv","wb");
    $fwrite(file,"%s\n", "value");
    #1 bonus_en = 1;
    #1 run_times(2);
    #1 bonus_en = 0;
    #1 run_times(24000);
    #1 bonus_en = 1;
    #1 run_times(500);
    #1 bonus_en = 0;
    #1 run_times(24000);
    #1 bonus_en = 1;
    #1 run_times(1000);
    #1 bonus_en = 0;
    #1 run_times(24000);
    #1 bonus_en = 1;
    #1 run_times(1000);
    #1 bonus_en = 0;
    #1 run_times(24000);
    #1 bonus_en = 1;
    #1 run_times(1000);
    #1 bonus_en = 0;
    #1 run_times(1000);
    #1 bonus_en = 1;
    #1 run_times(1000);
    #1 bonus_en = 0;
    #1 run_times(3000);
    #1 bonus_en = 1;
        #1 run_times(1000);
    #1 bonus_en = 0;
    #1 run_times(3000);
    #1 bonus_en = 1;
        #1 run_times(1000);
    #1 bonus_en = 0;
    #1 run_times(3000);
    #1 bonus_en = 1;
        #1 run_times(1000);
    #1 bonus_en = 0;
    #1 run_times(3000);
    #1 bonus_en = 1;
        #1 run_times(1000);
    #1 bonus_en = 0;
    #1 run_times(3000);
    #1 bonus_en = 1;
        #1 run_times(1000);
    #1 bonus_en = 0;
    #1 run_times(3000);
    #1 bonus_en = 1;
        #1 run_times(1000);
    #1 bonus_en = 0;
    #1 run_times(3000);
    #1 bonus_en = 1;
        #1 run_times(1000);
    #1 bonus_en = 0;
    #1 run_times(3000);
    #1 bonus_en = 1;
        #1 run_times(1000);
    #1 bonus_en = 0;
    #1 run_times(3000);
    #1 bonus_en = 1;
        #1 run_times(1000);
    #1 bonus_en = 0;
    #1 run_times(3000);
    #1 bonus_en = 1;
        #1 run_times(1000);
    #1 bonus_en = 0;
    #1 run_times(3000);
    #1 bonus_en = 1;
    #1 run_times(96000);
    #1;
    $fclose(file);
  end
    
endmodule
