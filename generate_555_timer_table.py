##################################################################################\
#
#  MiSTer Discrete lookup table generator for the astable 555 timer circuit
#
#  Copyright 2022 by Jegor van Opdorp. 
#  This program is free software under the terms of the GPLv3, see LICENCSE.txt
#
##################################################################################/

import math

class astable_555_timer:

    def __init__(self, r1,r2,c, vcc) -> None:
        self.r1 = r1
        self.r2 = r2
        self.c = c
        self.vcc = vcc

    # function from https://electronics.stackexchange.com/q/101530/277589
    def get_frequency_response(self, v_control):
        ln_vc_vcc_vc = math.log(1 - v_control / ((2*self.vcc) - v_control))
        c_r1_r2 = self.c * (self.r1 + self.r2)
        c_r2_ln2 = (self.c*self.r2) * math.log(2)
        return c_r1_r2 * ln_vc_vcc_vc + c_r2_ln2