import os.path
from argparse import ArgumentParser

from msdsl import RangeOf, AnalogSignal, MixedSignalModel, VerilogGenerator
from anasymod import get_full_path


# class Filter(MixedSignalModel):
#     def __init__(self, name='filter', res=1e3, cap=1e-9, dt=0.1e-6):
#         # call the super constructor
#         super().__init__(name, dt=dt)

#         # define I/O
#         self.add_analog_input('v_in')
#         self.add_analog_output('v_out')

#         c = self.make_circuit()
#         gnd = c.make_ground()

#         c.capacitor('net_v_out', gnd, cap, voltage_range=RangeOf(self.v_out))
#         c.resistor('net_v_in', 'net_v_out', res)
#         c.voltage('net_v_in', gnd, self.v_in)

#         c.add_eqns(
#             AnalogSignal('net_v_out') == self.v_out
#         )

class WalkEnAstable555(MixedSignalModel):
    R44 = 1200
    R45 = 10000
    R46 = 12000
    C29 = 0.0000033
    R_555_pullup = 5000
    R_555_pulldown = 10000
    
    def __init__(self, name='WalkEnAstable555', dt=1/96000):
        # call the super constructor
        super().__init__(name, dt=dt)

        # define I/O
        self.add_analog_input('walk_en')
        self.add_analog_input('square_wave')
        self.add_analog_input('vcc') # 12V, seems like this shouldn't be an input, but it doesn't compile otherwise
        self.add_analog_output('v_control')

        c = self.make_circuit()
        gnd = c.make_ground()

        c.voltage('net_walk_en', gnd, self.walk_en)
        c.voltage('net_square_wave', gnd, self.square_wave)
        c.voltage('net_vcc', gnd, self.vcc)

        c.resistor('net_walk_en', 'net_mix', self.R45)
        c.resistor('net_square_wave', 'net_mix', self.R46)
        c.resistor('net_mix', 'net_v_control', self.R44)
        c.capacitor('net_v_control', gnd, self.C29, voltage_range=RangeOf(self.v_control))
        c.resistor('net_v_control', 'net_vcc', self.R_555_pullup)
        c.resistor('net_v_control', 'net_gnd', self.R_555_pulldown)


        c.add_eqns(
            AnalogSignal('net_v_control') == self.v_control
        )

def main():
    print('Running model generator...')

    # parse command line arguments
    parser = ArgumentParser()
    parser.add_argument('-o', '--output', type=str)
    parser.add_argument('--dt', type=float)
    args = parser.parse_args()

    # create the model
    model = WalkEnAstable555(dt=args.dt)

    # determine the output filename
    filename = os.path.join(get_full_path(args.output), f'{model.module_name}.sv')
    print('Model will be written to: ' + filename)

    # generate the model
    model.compile_to_file(VerilogGenerator(), filename)

if __name__ == '__main__':
    main()