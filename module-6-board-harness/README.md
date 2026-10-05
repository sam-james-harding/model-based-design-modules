# Module 6: The board harness in Simulink

In Module 5, everything on the board apart from the filter was hand-written VHDL. This module moves the signal processing into Simulink so HDL Coder generates it as well, which leaves only the board I/O written by hand.

Besides the add-ons in the main README, you'll need the DSP System Toolbox for the CIC Decimation and Sine Wave blocks, and the Signal Processing Toolbox for `butter`, which `iir_setup` uses. You'll also need Vivado and the board.

| File | What it is |
|---|---|
| `mic_decimator.slx` | Turns the microphone's 1-bit stream into 16-bit samples. The input runs at the microphone's 3.125 MHz bit rate, and everything after the CIC decimator runs at 48.828 kHz |
| `board_audio.slx` | The rest of the audio path. Playback, plus a test tone if you want it, goes through the filter, bypass and mute and comes out as a PWM duty cycle. It also has the microphone level meter. HDL Coder turns the whole model into one VHDL entity |
| `iir_pipelined.slx` | The pipelined filter from Module 5, which `board_audio` uses through a Model block |
| `iir_setup.m` | Filter coefficients, data types and microphone settings. The models run it when they load |
| `generate_hdl.m` | Generates VHDL for `mic_decimator` and `board_audio`, filter included |

## Inside `mic_decimator.slx`

Each bit from the microphone becomes +1 or −1 and goes into a CIC Decimation block with 4 stages, which divides the rate by 64. The CIC runs at full precision, 26 bits. Its output is scaled by 2⁻²², and since the CIC's full scale is 2²⁴ that works out to a gain of 4. The microphone is fairly quiet, so it needs the boost.

Next, a DC blocker takes off the microphone's offset. It subtracts a running estimate of the DC level, and the estimate moves by 1/1024 of the output each sample, which makes a high-pass at about 8 Hz. Finally the signal is saturated to 16 bits. There are pipeline registers before the scaling and at the output.

## Inside `board_audio.slx`

The test tone comes from a Sine Wave block making 4.8 kHz at 1/8 of full scale, using a lookup table with 10 samples per period. The filter cuts it by about 25 dB. You can change its level with the Amplitude parameter, but if you change the frequency, keep it to a whole number of samples per period at 48 kHz.

The tone is switched in and added to the playback (saturating), then passes through a one-sample pipeline register, the filter, and the Bypass and Mute switches. To get a PWM duty cycle, the audio has 1 added and is put on an 11-bit scale, 0 to 2047.

The level meter is a MATLAB Function block. It finds the peak microphone level over each 0.17 s and shows it as a bar on 15 LEDs, 6 dB per LED.

## Putting it on the board

The Vivado project is for the original Nexys4, with DSP slices turned off.

1. Run `generate_hdl.m`. The VHDL goes into `work/hdlsrc/mic_decimator/` and `work/hdlsrc/board_audio/`.
2. The first time only, open the Tcl console in Vivado, `cd` to `vivado/` and run `source create_project.tcl` to make `nexys4_iir.xpr`. The project reads the generated VHDL straight out of `work/hdlsrc/`, so after changing a model you only need to redo step 1.
3. Open `vivado/nexys4_iir.xpr`, click Generate Bitstream, and program the board from the Hardware Manager.

On the board, hold BTNC to record from the microphone. The speaker is muted while you do. Let go and the recording plays on a loop. SW0 bypasses the filter and lights LED0, SW1 adds the test tone before the filter, and LED1 to LED15 show the microphone level.

The board I/O is still VHDL, in `vivado/src/`.

- `nexys4_top.vhd` is the top level. Apart from synchronising the buttons and switches, it's just wiring between the microphone clock, the generated `mic_decimator`, the recorder, the generated `board_audio` and the PWM output. The decimator's `ce_out` pulses once per sample, and that sets the pace for everything after it. The longest recording is set by the `RECORD_MS` generic, which defaults to 4000 ms.
- `mic_clock.vhd` makes the 3.125 MHz microphone clock (100 MHz / 32), reads each data bit, and flags it with a one-cycle enable.
- `recorder.vhd` is the block RAM buffer that records the audio and loops it.
- `pwm_out.vhd` is the 11-bit PWM output. It's a counter compared against the duty cycle, running at 48.828 kHz.
- `nexys4.xdc` has the pin assignments. The audio pin is driven push-pull, which this board needs.
- `tb_nexys4_top.vhd` simulates the whole harness (Run Simulation in the project takes about 4 minutes). It pretends to be the microphone playing a tone while BTNC is held, and checks the output stays quiet during recording. Then it measures the tone at the PWM pin with the filter on, bypassed, and with the test tone added, and checks the level meter LEDs.

Both models use synchronous resets. Xilinx recommends that here because the recorder's block RAMs are enabled by the decimator's `ce_out`.

To use the original filter instead, copy `iir_original.slx` across from Module 5 and point the Model block in `board_audio.slx` at `iir_original`.

Generated files (HDL and the Simulink cache) all go in `work/`. You can delete it any time, but redo step 1 before building in Vivado again.
