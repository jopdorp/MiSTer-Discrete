import sys
import numpy as np
from scipy.io import wavfile

def wav_to_txt(input_file, output_file):
    fs, data = wavfile.read(input_file)
    data = data / np.max(np.abs(data))  # normalize the data
    times = np.arange(len(data)) / fs  # calculate the time of each sample
    with open(output_file, 'w') as f:
        for t, sample in zip(times, data):
            f.write(f'{t} {sample}\n')

if __name__ == "__main__":
    input_file = sys.argv[1]
    wav_to_txt(input_file, 'input.txt')