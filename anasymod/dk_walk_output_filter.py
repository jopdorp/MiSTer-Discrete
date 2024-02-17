from msdsl import RangeOf, AnalogSignal, MixedSignalModel

# On 2024-02-17, this wasn't compatible with the integer logic converter yet
class DkWalkOutputFilter(MixedSignalModel):
    R18 = 4700
    C25 = 0.0000033
    R17 = 10000
    R35 = 1000
    C23 = 0.0000047
    R16 = 5600
    C22 = 0.000000047
    R15 = 5600
    R14 = 47000
    C12 = 0.000001
    R1  = 10000

    def __init__(self, name='DkWalkOutputFilter', dt=1/96000):
        # call the super constructor
        super().__init__(name, dt=dt)

        # define I/O
        self.add_analog_input('walk_en')
        self.add_analog_input('modulated_555_pulse')
        self.add_analog_output('audio_out')

        c = self.make_circuit()
        gnd = c.make_ground()

        c.voltage('net_walk_en', gnd, self.walk_en)
        c.voltage('net_modulated_555_pulse', gnd, self.modulated_555_pulse)

        c.resistor('net_walk_en', 'net_r18_c25', self.R18)
        c.capacitor('net_r18_c25', 'net_c25_r35', self.C25, voltage_range=RangeOf(self.walk_en))
        
        c.diode(gnd, 'net_c25_r35')
        c.resistor(gnd, 'net_c25_r35', self.R17)
        c.resistor('net_c25_r35', 'net_modulated_555_pulse', self.R35)
        c.capacitor('net_modulated_555_pulse', 'net_r35_r16', self.C23, voltage_range=RangeOf(self.modulated_555_pulse))
        c.resistor('net_r35_r16', 'net_r16_r14', self.R16)
        c.capacitor(gnd, 'net_r16_r14', self.C22, voltage_range=RangeOf(self.modulated_555_pulse))
        c.resistor(gnd, 'net_r16_r14', self.R15)
        c.resistor('net_r14', 'net_audio_out', self.R14)
        # This capacitor causes Singular Matrix Error, this would have been a high pass filter with a cutoff frequency of 15.9Hz
        # That means it's kind of a dc offset filter, it won't affect the wat it sounds
        # c.capacitor('net_audio_out', 'net_c12_r1', self.C12, voltage_range=RangeOf(self.modulated_555_pulse))
        c.resistor(gnd, 'net_audio_out', self.R1)

        c.add_eqns(
            AnalogSignal('net_audio_out') == self.audio_out
        )
