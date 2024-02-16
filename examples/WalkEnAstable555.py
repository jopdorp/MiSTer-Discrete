
import pandas as pd

VCC = 5.0

def get_next_sample(tmp_circ_4, walk_en_5volts_filtered, square_osc_out):
    tmp0 = 0.9988949505878484 * tmp_circ_4
    tmp1 = 0.0006309642509321234 * VCC
    tmp2 = 0.00025859190611972273 * walk_en_5volts_filtered
    tmp3 = 0.00021549325509976887 * square_osc_out
    tmp4 = tmp0 + tmp1
    tmp5 = tmp2 + tmp3
    tmp6 = tmp4 + tmp5
    return tmp6


def to_16_bit_signed(tmp_circ_4):
    return tmp_circ_4 / VCC * 2**14

def from_16_bit_signed(var):
    return var * VCC / 2**14

def WalkEnAstable555():
    inputs = ['walk_en_5volts_filtered', 'square_osc_out']
    prefix = 'dk_walk_'
    extension = '.csv'
    # Read input files
    walk_en_5volts_filtered = pd.read_csv(prefix + inputs[0] + extension, header=None)[0].tolist()
    square_osc_out = pd.read_csv(prefix + inputs[1] + extension, header=None)[0].tolist()
    # Initialize variables
    tmp_circ_4 = 2.5

    outputs = []
    # Iterate over the samples
    for i in range(len(walk_en_5volts_filtered)):
        tmp_circ_4 = get_next_sample(
            tmp_circ_4, 
            from_16_bit_signed(int(walk_en_5volts_filtered[i])), 
            from_16_bit_signed(int(square_osc_out[i]))
        )
        # Take oversampling into account
        if i % 2 == 0:
            outputs.append(to_16_bit_signed(tmp_circ_4))
    return outputs

outputs = WalkEnAstable555()

# Write output csv file, each row is a sample
df = pd.DataFrame(outputs)
df.to_csv('dk_walk_v_control_python.csv', index=False, header=False)

# run convert_to_wav.py, pass the csv filename as argument
import sys
import subprocess

subprocess.run([sys.executable, '../convert_to_wav.py', 'dk_walk_v_control_python.csv'])
