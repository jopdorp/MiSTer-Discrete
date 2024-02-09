#include "Vdk_walk.h"
#include "verilated.h"
#include <iostream>
#include <fstream>

#define CLOCK_RATE 12 * 48000 * 2
#define SAMPLE_RATE 48000 * 2
#define CYCLES_PER_SAMPLE CLOCK_RATE / SAMPLE_RATE * 2
#define HIGH_TIME 1
#define LOW_TIME 6

int main(int argc, char **argv, char **env) {
    Verilated::commandArgs(argc, argv);
    Vdk_walk* top = new Vdk_walk;

    std::ofstream file("dk_walk.csv");

    top->clk = 0;
    top->I_RSTn = 1;
    top->audio_clk_en = 0;
    top->walk_en = 0;

    for (int i = 0; i < 8; ++i) {
        top->walk_en = 1;
        for (int j = 0; j < HIGH_TIME * CYCLES_PER_SAMPLE * 1400; ++j) {
            top->clk = !top->clk;
            if (j % CYCLES_PER_SAMPLE == CYCLES_PER_SAMPLE - 2) {
                top->audio_clk_en = 1;
            } else if (j % CYCLES_PER_SAMPLE == CYCLES_PER_SAMPLE - 1) {
                top->audio_clk_en = 0;
                file << top->O_SOUND_DAT << "\n";
            }
            top->eval();
        }
        top->walk_en = 0;
        for (int j = 0; j < LOW_TIME * CYCLES_PER_SAMPLE * 1400; ++j) {
            top->clk = !top->clk;
            if (j % CYCLES_PER_SAMPLE == CYCLES_PER_SAMPLE - 2) {
                top->audio_clk_en = 1;
            } else if (j % CYCLES_PER_SAMPLE == CYCLES_PER_SAMPLE - 1) {
                top->audio_clk_en = 0;
                file << top->O_SOUND_DAT << "\n";
            }
            top->eval();
        }
    }

    file.close();
    delete top;
    return 0;
}