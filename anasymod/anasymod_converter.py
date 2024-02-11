import os.path
from argparse import ArgumentParser

from msdsl import VerilogGenerator
import subprocess

def to_camel_case(s):
    s = s.title().split('_')
    return s[0] + ''.join(word.title() for word in s[1:])

def main():
    print('Running model generator...')

    # parse command line arguments
    parser = ArgumentParser()
    parser.add_argument('-m', '--model', type=str)
    parser.add_argument('-f', '--clock_enable_frequency', type=int, default=96000)
    parser.add_argument('-v', '--vcc', type=int, default=5)
    args = parser.parse_args()

    # read the ModelClass from the model file, the filename is passed as an argument, the ModelClaas is filename converted to CamelCase
    ModelClass = to_camel_case(args.model)
    namespace = {}
    exec(f'from {args.model} import {ModelClass}', namespace)
    model_class = namespace[ModelClass]
    model = model_class(dt=1/args.clock_enable_frequency)
    
    # determine the output filename
    filename = f'{model.module_name}.sv'
    print('Model will be written to: ' + filename)

    # generate the model
    model.compile_to_file(VerilogGenerator(), filename)
    subprocess.call(["python", "anasymod_to_integer_logic.py", "-i", filename])


if __name__ == '__main__':
    main()