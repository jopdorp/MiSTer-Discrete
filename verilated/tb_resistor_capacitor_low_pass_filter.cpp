#include <stdlib.h>
#include <iostream>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vresistor_capacitor_low_pass_filter.h"
#include "Vresistor_capacitor_low_pass_filter_resistor_capacitor_low_pass_filter.h"
#define DR_WAV_IMPLEMENTATION
#include "dr_wav.h"

#define MAX_SIM_TIME 48000 * 4 * 67
vluint64_t sim_time = 0;

int main(int argc, char** argv, char** env) {
    Vresistor_capacitor_low_pass_filter *filter = new Vresistor_capacitor_low_pass_filter;

    drwav input;
    if (!drwav_init_file(&input, "./mdfourier-dac-192000-left.wav", NULL)) {
        printf("Failed to open input file.\n");
        return -1;
    }

    int16_t* pSampleData = (int16_t*)malloc((size_t)input.totalPCMFrameCount * input.channels * sizeof(int16_t));
    drwav_read_pcm_frames_s16(&input, input.totalPCMFrameCount, pSampleData);
    drwav_uninit(&input);

    drwav_data_format format;
    drwav output;

    format.container     = drwav_container_riff;
    format.format        = DR_WAVE_FORMAT_PCM;
    format.channels      = 1;
    format.sampleRate    = 48000 * 4;
    format.bitsPerSample = 16;
    if (!drwav_init_file_write(&output, "filtered_192000_left.wav", &format, NULL)) {
        printf("Failed to open output file.\n");
        return -1;
    }

    filter->I_RSTn = 1;
    while (sim_time < MAX_SIM_TIME) {
        filter->in = *pSampleData / 2;
        pSampleData = pSampleData + 2;
        for(int i = 0; i < 2; i++){
            filter->audio_clk_en = i % 2;
            filter->clk = 0;
            filter->eval();
            filter->clk = 1;
            filter->eval();
        }
        short out = ((short)filter->out) / 2;
        drwav_write_pcm_frames(&output, 1, &out);
        sim_time++;
    }
    filter->final(); 
    drwav_uninit(&output);
    delete filter;
    exit(EXIT_SUCCESS);
}