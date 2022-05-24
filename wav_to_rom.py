#!/usr/bin/python3

import wave, struct
import argparse

def write_rom(wav_file, var_name, seconds):
    with wave.open(wav_file, 'r') as wav:
        frames = wav.readframes(48000 * seconds);
        samples = struct.unpack(f'<{48000 * 2 * seconds}h', frames)
        with open(f'{wav_file}.sv', 'w') as rom:
            rom.writelines([f'{var_name}[{i}]={line + 32768};\n'  for i, line in enumerate(samples)])

if __name__ == "__main__":
	parser = argparse.ArgumentParser()
	parser.add_argument("wav_file")
	parser.add_argument("var_name")
	parser.add_argument("length_seconds")
	args = parser.parse_args()

	write_rom(args.wav_file, args.var_name, args.length_seconds)