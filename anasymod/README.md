# Anasymod integration with MiSTer-Discrete

## What it is
Anasymod is a library that can convert mixed-signal circuits defined in python into SystemVerilog
It will create a discretized floating point implementation of the circuit. 
The resulting file includes a lot of macros that will work in xilinx, but won't in most other tooling.
Because of this, MiSTer-Discrete includes a compiler that wil convert the output of anasymod into a fixed-point core.


## Usage

Create a file with a snake_case name that contains a CamelCase python class with the same name.
The python class will contain a description of a circuit, using anasymod.
Once the circuit is done you can convert it into a MiSTer-Discrete compatible core like this:
```
python ./anasymod_converter.py -m walk_en_astable_555 -f 96000 -v 5
```

In the above `-f 96000` is the `clk_enable` frequency. It's advisable to use oversampling. In this case the `audio_clk_enable` might be `48000`.
The `-v 5` argument is the `vcc` voltage, this has to be the same `vcc` as in the rest of your MiSTer-Discrete analog simulation core.

The script will output a file called `fixed_point_WalkEnAstable555.sv` this file is compatible with MiSTer-Discrete and quartus 17.0 and can be used in your core.