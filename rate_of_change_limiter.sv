module rate_of_change_limiter #(
    parameter VCC = 12,
    parameter SAMPLE_RATE = 48000,
    parameter MAX_CHANGE_RATE = 1000 //10 V/s
) (
    input clk,
    input audio_clk_en,
    input signed[15:0] in,
    output reg signed[15:0] out = 0
);
    localparam longint MAX_CHANGE_PER_SAMPLE = (MAX_CHANGE_RATE << 14) / VCC / SAMPLE_RATE;

    wire signed[15:0] difference;
    assign difference = in - out;
    always @(posedge clk) begin
        if(difference < -MAX_CHANGE_PER_SAMPLE)begin
            out <= out - MAX_CHANGE_PER_SAMPLE;
        end else if(difference > MAX_CHANGE_PER_SAMPLE) begin
            out <= out + MAX_CHANGE_PER_SAMPLE;
        end else begin
            out <= in; 
        end
    end
endmodule