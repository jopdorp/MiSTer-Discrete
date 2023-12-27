import sys
import numpy as np
from scipy.io import wavfile

def txt_to_wav(input_file, output_file, fs):
    data = np.loadtxt(input_file)  # load the data
    times, samples = data[:, 0], data[:, 1]
    samples = (samples * 32767).astype(np.int16)  # convert to 16-bit PCM
    wavfile.write(output_file, fs, samples)

if __name__ == "__main__":
    output_file = sys.argv[1]
    txt_to_wav('output.txt', output_file, 48000)