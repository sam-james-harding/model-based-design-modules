# Module 2: Four-to-four switch

The switch has four 8-bit inputs, D0 to D3, and four outputs, Y0 to Y3. `sel_in` picks an input and `sel_out` picks which output it goes to, and the other three outputs stay at 0. As in Module 1, we build it in VHDL, MATLAB and Simulink. This time we also run the Simulink version on the board using FPGA-in-the-loop.

| File | What it is |
|---|---|
| `vivado/src/Switch.vhd` | The hand-written VHDL. It's the top level, with a mux feeding a demux |
| `vivado/src/Mux.vhd`, `vivado/src/Demux.vhd` | The mux and demux |
| `four_to_four_switch_matlab.m` | The MATLAB version |
| `test_four_to_four_switch.m` | Testbench for the MATLAB version, which tries 100 random cases |
| `four_to_four_switch_simulink.slx` | The Simulink version. The switch itself is the `four_to_four_switch` subsystem, built from Multiport Switch blocks, and the blocks around it feed in test inputs and save the outputs |

## Running it

For the hand-written version, make a Vivado project for the Nexys4 (`xc7a100tcsg324-1`), add the three files in `vivado/src/`, set `Switch.vhd` as the top module, and run synthesis.

For the MATLAB version, run `test_four_to_four_switch` to check it works. Then open the HDL Coder app with `hdlcoder` and use `four_to_four_switch_matlab.m` as the design and `test_four_to_four_switch.m` as the testbench.

The Simulink model reads its inputs from workspace variables called `D0`, `D1`, `D2`, `D3`, `sel_in` and `sel_out`, one value per second, and saves the outputs as `Y0` to `Y3`. This sets up ten random inputs and runs it:

```matlab
t = (0:9)';
D0 = timeseries(randi([0 255], 10, 1), t);   D1 = timeseries(randi([0 255], 10, 1), t);
D2 = timeseries(randi([0 255], 10, 1), t);   D3 = timeseries(randi([0 255], 10, 1), t);
sel_in  = timeseries(randi([0 3], 10, 1), t);
sel_out = timeseries(randi([0 3], 10, 1), t);
out = sim('four_to_four_switch_simulink', 'StopTime', '9');
```

## FPGA-in-the-loop

The model is already set up for FPGA-in-the-loop on the Nexys4. Open the HDL Workflow Advisor on the `four_to_four_switch` subsystem and run all its tasks. It builds a bitstream and makes a copy of the model, `gm_four_to_four_switch_simulink_fil.slx`, where the switch has been swapped for an FPGA-in-the-loop block.

Plug the board in over USB, load the bitstream from that block, and simulate the copy with the same workspace inputs as before. The switch then runs on the FPGA, with Simulink sending it inputs and reading back the outputs.
