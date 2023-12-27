from subprocess import call
import os
import argparse

import numpy as np

from scipy.io import wavfile
from scipy.signal import butter, lsim, lfilter
import matplotlib.pyplot as plt
from scipy.signal import bode

def wav_to_txt(input_file, output_file):
    fs, data = wavfile.read(input_file)
    data = data / np.max(np.abs(data))  # normalize the data
    times = np.arange(len(data)) / fs  # calculate the time of each sample
    with open(output_file, 'w') as f:
        for t, sample in zip(times, data):
            f.write(f'{t} {sample}\n')

def txt_to_wav(input_file, output_file, fs):
    data = np.loadtxt(input_file)  # load the data
    times, samples = data[:, 0], data[:, 1]
    samples = (samples * 32767).astype(np.int16)  # convert to 16-bit PCM
    wavfile.write(output_file, fs, samples)


def generate_netlist(input_file, output_file, simulation_length):
    # Read the data from the input file and format it into a PWL string
    with open(input_file, 'r') as f:
        data = f.read().strip().replace('\n', ' ')
    pwl_string = f'PWL({data})'

    # Check the length of the input wav file in seconds

    # Generate the netlist
    with open('high_pass.cir', 'w') as f:
        f.write(f"""
* High-pass RC filter
.OPTIONS
Vin 1 0 DC 0 {pwl_string}
R1 1 2 47k
C1 2 0 47nF
.TRAN {1/48}ms {simulation_length}s UIC
.control
run
wrdata {output_file} v(2)
.endc
.END
""")

def butterworth_filter(R, C, input_file, output_file):
    fs, data = wavfile.read(input_file)
    print(f'data: {data}')  # Debug print
    data = data / np.max(np.abs(data))  # normalize the data
    times = np.linspace(0, len(data)/fs, len(data), endpoint=False)  # continuous time array
    b, a = butter(1, 1/(2*np.pi*R*C), 'highpass', analog=True)
    print(f'b: {b}, a: {a}')  # Debug print
    w, mag, phase = bode((b, a))  # compute Bode magnitude and phase data

    # plot Bode magnitude and phase data
    plt.figure()
    plt.semilogx(w, mag)  # Bode magnitude plot
    plt.figure()
    plt.semilogx(w, phase)  # Bode phase plot
    plt.show()

    filtered_data = lsim((b, a), data, times)[1]
    print(f'filtered_data before normalization: {filtered_data}')  # Debug print
    filtered_data = filtered_data / np.max(np.abs(filtered_data))  # normalize the data
    filtered_data = (filtered_data * 32767).astype(np.int16)  # convert to 16-bit PCM
    wavfile.write(output_file, fs, filtered_data)
    
def apply_filter(input_file, output_file, length):
    # use ngspice to run high_pass.cir
    generate_netlist(input_file, output_file, length)
    call(['/usr/bin/ngspice', '-b', 'high_pass.cir'])


def merge_wavs(left_file, right_file, output_file):
    left_data = wavfile.read(left_file)[1]
    right_data = wavfile.read(right_file)[1]
    stereo_data = np.column_stack((left_data, right_data))
    wavfile.write(output_file, 48000, stereo_data)

def get_wav_length(input_file):
    return os.popen(f'ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 {input_file}').read().strip()
    
if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--type', choices=['butterworth', 'spice'], default='butterworth')
    args = parser.parse_args()

    # get args type
    if args.type == 'butterworth':
        # R=47k, C-47nF
        butterworth_filter(47000, 0.047, 'mdfourier-dac-48000-left.wav', 'filtered-left.wav')
        butterworth_filter(47000, 0.047, 'mdfourier-dac-48000-right.wav', 'filtered-right.wav')
    elif args.type == 'spice':  # Fixed typo: changed 'type' to 'args.type'
        wav_to_txt('mdfourier-dac-48000-left.wav', 'left.txt')
        apply_filter('left.txt', 'filtered-left.txt', get_wav_length('mdfourier-dac-48000-left.wav'))
        txt_to_wav('filtered-left.txt', 'filtered-left.wav', 48000)

        wav_to_txt('mdfourier-dac-48000-right.wav', 'right.txt')
        apply_filter('right.txt', 'filtered-right.txt', get_wav_length('mdfourier-dac-48000-right.wav'))
        txt_to_wav('filtered-right.txt', 'filtered-right.wav', 48000)

    merge_wavs('filtered-left.wav', 'filtered-right.wav', 'filtered-stereo.wav')