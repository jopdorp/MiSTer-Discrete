#include <stdlib.h>
#include <iostream>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vresistor_capacitor_high_pass_filter.h"
#define DR_WAV_IMPLEMENTATION
#include "dr_wav.h"

vluint64_t sim_time = 0;

short process_channel(Vresistor_capacitor_high_pass_filter *filter, int16_t* &pSampleData) {
    filter->in = *pSampleData / 2;
    pSampleData = pSampleData + 2;
    for(int i = 0; i < 2; i++){
        filter->audio_clk_en = i % 2;
        filter->clk = 0;
        filter->eval();
        filter->clk = 1;
        filter->eval();
    }
    return ((short)filter->out) / 2;
}

int main(int argc, char** argv, char** env) {
    Vresistor_capacitor_high_pass_filter *filter = new Vresistor_capacitor_high_pass_filter();

    drwav input;
    if (!drwav_init_file(&input, "./mdfourier-dac-48000.wav", NULL)) {
        printf("Failed to open input file.\n");
        return -1;
    }

    // Calculate the total number of samples
    size_t totalSamples = input.totalPCMFrameCount * input.channels;

    // Allocate memory for the samples
    int16_t* pSampleData = (int16_t*)malloc(totalSamples * sizeof(int16_t));
    int16_t* pSampleDataEnd = pSampleData + totalSamples;
    drwav_read_pcm_frames_s16(&input, input.totalPCMFrameCount, pSampleData);
    drwav_uninit(&input);

    drwav_data_format format;
    drwav output;

    format.container     = drwav_container_riff;
    format.format        = DR_WAVE_FORMAT_PCM;
    format.channels      = 2; // Set the output file to stereo
    format.sampleRate    = input.sampleRate;
    format.bitsPerSample = 16;
    if (!drwav_init_file_write(&output, "./high_filtered_mdfourier-dac-48000.wav", &format, NULL)) {
        printf("Failed to open output file.\n");
        return -1;
    }

    printf("Writing wav file...\n");
    filter->I_RSTn = 1;

    int16_t* pSampleDataLeft = pSampleData;
    int16_t* pSampleDataRight = pSampleData + 1;

    while (true) {
        // Check that pSampleData doesn't go beyond the end of the allocated memory
        if (pSampleDataRight >= pSampleDataEnd) {
            break;
        }

        // Process the left and right channels
        short outLeft = process_channel(filter, pSampleDataLeft);
        short outRight = process_channel(filter, pSampleDataRight);

        // Write the left and right channels to the output file
        int16_t out[2] = {outLeft, outRight};
        drwav_write_pcm_frames(&output, 1, out);
        sim_time++;
    }

    printf("Finishing...\n");

    filter->final(); 
    drwav_uninit(&output);
    // Print final result
    printf("Done!\n");
    delete filter;
    exit(EXIT_SUCCESS);
}