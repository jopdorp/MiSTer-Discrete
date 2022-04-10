import sys
import pandas as pd
import soundfile as sf

def convert_to_wav(path):
    df = pd.read_csv(path)
    data = df.values.astype('int32') * 2 ** 15
    sf.write(path+'.wav', data, sample_rate_hz)

sample_rate_hz = 48000
convert_to_wav(sys.argv[1])
