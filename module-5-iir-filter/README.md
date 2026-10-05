# Module 5: IIR filter on an FPGA

The filter here is a second-order Butterworth low-pass, cutting off at 1 kHz with a 48 kHz sample rate. We build it in Simulink, use look-ahead pipelining to get an extra register into its feedback loop, choose a coefficient word length, test it against a double-precision version with an audio clip, and then run it on the Nexys4 using the board's microphone.

Besides the add-ons in the main README, you'll need the Signal Processing Toolbox for `butter`, `freqz` and `resample`. Step 6 also needs Vivado and the board.

## Running it

Run the step scripts in order, from this folder. Each one starts by running `iir_setup`, which sets up the coefficients, data types and audio clip. The models run it too when they load. Steps 1 and 4 play audio, so turn your sound on.

The Slides column gives the matching slide numbers in the Module 5 slides.

| File | Slides | What it does |
|---|---|---|
| `iir_setup.m` | 3, 11 | Sets the filter and look-ahead coefficients, the word lengths and the audio clip |
| `iir_original.slx` | 8 | The filter built straight from its difference equation with Gain, Sum and Delay blocks. There's one register in the feedback loop |
| `iir_pipelined.slx` | 12–15 | The look-ahead version, with two registers in the loop, one on each side of the multiplier |
| `step1_filter.m` | 3, 8 | Plays the clip before and after filtering, and checks `iir_original` against MATLAB's `filter()` |
| `step2_pipelined.m` | 11–16 | Shows the two filters give the same output in double precision but not quite in fixed point |
| `step3_wordlength.m` | 20, 30 | Plots both filters' frequency response with 4, 8 and 16-bit coefficients and prints the worst error. Takes about 20 seconds |
| `step4_testbench.m` | 23–24 | The audio testbench. The noisy clip goes through a double-precision reference (`filter()`) and the fixed-point model. It plots the difference against the tolerance `tol`, prints the largest difference, and plays both |
| `step5_response.m` | 25 | Measures the frequency response by putting an impulse through the model, and plots it over the ideal response |
| `step6_board.m` | 27–28 | Generates the VHDL for the board |
| `simfilter.m` | | Used by the steps to run a filter model on some samples, either in fixed point or with everything switched to double |

## Putting it on the board

The Vivado project is for the original Nexys4, with DSP slices turned off so the multipliers are built from LUTs.

1. Run `step6_board.m`. The filter's VHDL goes into `work/hdlsrc/iir_pipelined/`.
2. The first time only, open the Tcl console in Vivado, `cd` to the `vivado/` folder and run `source create_project.tcl`. This makes `nexys4_iir.xpr`. The project reads the filter straight out of `work/hdlsrc/`, so if you change the model later you only need to redo step 1.
3. Open `vivado/nexys4_iir.xpr`, click Generate Bitstream, and program the board from the Hardware Manager.

Once it's running, hold BTNC to record from the microphone. The speaker is muted while you record so you don't get feedback. When you let go, the recording loops through the filter and out of the audio jack. Flip SW0 up to bypass the filter (LED0 lights up), which lets you hear the same clip with and without it. SW1 adds hiss before the filter. LED1 to LED15 show the microphone level, 6 dB per LED.

The VHDL in `vivado/src/` is the harness that sits around the filter on the board.

- `nexys4_top.vhd` is the top level. It handles recording and playback, the bypass and hiss switches and the level meter, and sends the audio out as 11-bit PWM. The hiss is white noise minus itself four samples earlier, which peaks at about 6 kHz. Its level is the shift in the `hiss :=` line, 6 dB per step. The longest recording is set by the `RECORD_MS` generic, which defaults to 4000 ms. The audio pin is driven push-pull, which this board needs.
- `recorder.vhd` is the block RAM buffer that records the audio and loops it.
- `pdm_mic.vhd` makes the 3.125 MHz microphone clock and turns the microphone's 1-bit stream into 16-bit samples with a 4th-order CIC decimator that divides the rate by 64. It also takes out the microphone's DC offset with a high-pass at about 8 Hz. A sample comes out every 2048 clock cycles, which is 48.828 kHz.
- `nexys4.xdc` has the pin assignments.
- `tb_nexys4_top.vhd` simulates the whole thing (use Run Simulation in the project). It pretends to be the microphone playing a tone while BTNC is held, checks the output stays quiet during recording, and then measures the tone at the PWM pin with the filter on, bypassed, and with hiss added.

To put the original filter on the board instead, generate `iir_original`, change the filter's entity name in `nexys4_top.vhd`, and change `iir_pipelined` to `iir_original` on the `add_files` line of `create_project.tcl`.

Generated files (HDL and the Simulink cache) all go in `work/`. You can delete it any time, but redo step 1 before building in Vivado again.

Module 6 takes this same harness and moves the signal processing into Simulink.
