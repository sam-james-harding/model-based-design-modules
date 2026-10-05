# Module 3: Multi-input adder

This module adds eight 8-bit numbers in Simulink, then uses HDL Coder's reports and Vivado's timing results to see how the adder turns out in hardware.

| File | What it is |
|---|---|
| `multi_adder.slx` | The model (more below) |
| `multi_adder_tb.m` | Testbench. It puts 1000 random sets of inputs through the model, compares each output with the exact sum, and plots a histogram of the errors. A mean squared error of 0 means every sum was right |
| `vivado/src/nexys4.xdc` | A 100 MHz clock constraint, for checking timing in Vivado |

The adder itself is the `multi_adder` subsystem. A Mux gathers the eight inputs into one signal and a Sum of Elements block adds them up, with a register before and after. The output is 11 bits wide, which is enough for the biggest possible sum (8 × 255 = 2040). HDL Coder is set to build the sum as a tree of adders, to estimate the critical path, and to aim for 100 MHz.

## Running it

Run `multi_adder_tb` to simulate. It loads the model itself.

To generate VHDL, use the HDL Workflow Advisor on the `multi_adder` subsystem, or run

```matlab
makehdl('multi_adder/multi_adder')
```

The VHDL goes in `hdl_prj/hdlsrc/multi_adder/`, and HDL Coder highlights the estimated critical path on the model. If you'd also like a count of adders and registers, turn on the resource utilization report under Configuration Parameters > HDL Code Generation > Report.

To check timing, make a Vivado project for the Nexys4 (`xc7a100tcsg324-1`), add the generated `.vhd` files and `vivado/src/nexys4.xdc`, and run implementation. The timing summary will tell you whether it makes 100 MHz.
