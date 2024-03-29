# MiSTer Discrete

This is an effort to make the real-time simulation of analog circuits possible on MiSTer.
## Why this is needed

* Many old computers have analog circuits that are a step between the tape input and the chip.
* Many old arcade games have analog sound synthesis circuits
  
Implementing analog behavior on FPGA is difficult. They don't have enough resources for a full-scale SPICE-type circuit simulation.
Samples are an option in some cases, but not flexible enough to simulate many types of analog signals. Even some signals that seem to behave the same every time, are actually more varied and richer when coming from an actual analog board or circuit-simulation.

Because of this, core developers have to come up with their own ways to implement the analog parts of these systems.

To make these efforts reusable, we have to follow a discipline, so all the subcircuits will work well together. 

## How it works

MiSTer Discrete is not a circuit simulation in the traditional sense.

In MiSTer Discrete, there is no way of transferring energy from one module to another,
or storing energy. It is not an energy based simulation.

Because of this, simulating arbitrary electronic circuits is not supported.
Instead, common subcircuits found on analog PCB boards are implemented as simplified models.
As a core builder, you can connect these simplified models together to create an analog PCB simulation.

## The formal engineering discipline

Each subcircuit is implmented as a module that can be instantiated with parameters:
* values of electronic parts such as resistors and capacitors.
* CLOCK_RATE in hz
* SAMPLE_RATE in hz
  
ports:
* input wire clk, audio_clk_en
* input signed wire[15:0] \<input name\>; // optinonal signed input signals
* output signed reg[15:0] out; // signed output signal

VCC, or v_plus is equivalent to {14{1'b1}} on the output or input signals.
This leaves some room for voltages that are higher than VCC, caused by capacitors/filters;
Ground, or v_ref is equivalent to 0 on the output or input signals.

Each time audio_clk_en goes high, the modules set their outputs as a direct relationship between their individual current state and their input signals.

## Setting up your environment
Anasymod needs python 3.7, so that's what we'll use:
```
sudo apt install python3.7
sudo apt install python3.7-venv
/usr/bin/python3.7 -m venv venv
pip install -r requirements.txt
```

## Testing modules

Modules are accompanied by testbenches that output csv and wav files.
The testbenches can be run using the run_sound_testbench.sh script.

You can try
```
$ run_sound_testbench.sh invertor_square_wave_oscilator
```

This wil ouput the files `invertor_square_wave_oscilator.csv` and `invertor_square_wave_oscilator.csv.wav`

## Creating new modules

Whenever you encounter a subcircuit that isn't implemented yet, you can implement it as a module adhereing to the discipline described in this document. This will make it compatible with the other modules from MiSTer Discrete.

`invertor_square_wave_oscilator.sv` and `invertor_square_wave_oscilator_tb.sv` can be taken as an example to write new modules and the accompanying testbench.

Prefer modules that model small subcircuits over models of complex large circuits.
This will make the chances of reusability higher.
Think about how common a certain subcircuit might be, when choosing how to break up a circuit into modules of smaller subcircuits.

When you have completed and tested you module, create a pull request, and one of the core developers will review and merge it :)

## Anasymod

Some circuits are difficult to implement without a more generic circuit simulator, for these cases we use anasymod.
See anasymode/README.md in this repository.