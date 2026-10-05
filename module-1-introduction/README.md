# Module 1: Introduction to HDL Coder

A first look at HDL Coder, using about the simplest design there is: Y = 2X + 5 on 8-bit unsigned numbers. We build it by hand in VHDL, then in Simulink, then in MATLAB, so you can put HDL Coder's output next to the hand-written version and compare.

| File | What it is |
|---|---|
| `vivado/src/converter.vhd` | The hand-written VHDL |
| `converter_simulink.slx` | The Simulink version, made from a Gain (×2), a Constant (5) and an Add block |
| `converter_matlab.m` | The MATLAB version |
| `test_converter.m` | Testbench for `converter_matlab`. It checks every input from 0 to 255, and HDL Coder also uses it to work out that X is a uint8 |

## Running it

To try the hand-written version, make a new Vivado project for the Nexys4 (part `xc7a100tcsg324-1`), add `vivado/src/converter.vhd`, and open the elaborated design or run synthesis.

For the Simulink version, open `converter_simulink.slx` and run

```matlab
makehdl('converter_simulink')
```

or use the HDL Workflow Advisor. The VHDL ends up in `hdlsrc/converter_simulink/`.

For the MATLAB version, run `test_converter` first. It should print `All 256 tests passed.` Then type `hdlcoder` to open the HDL Coder app, start a project with `converter_matlab.m` as the design and `test_converter.m` as the testbench, and work through the steps.

## Overflow

2X + 5 only fits in 8 bits up to X = 125, and past that the versions disagree. The VHDL and the Simulink model wrap around, so X = 126 gives 1. MATLAB saturates integer maths instead, so `converter_matlab` gives 255 for anything from 126 up.
