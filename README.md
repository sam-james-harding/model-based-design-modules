# Model-Based Design Modules

This is the code for the CSSE4010 model-based design modules. Each module has its own folder with the MATLAB scripts, Simulink models and VHDL from the videos, so you can follow along or try things yourself.

| Module | Description | Vivado | Board |
|---|---|---|---|
| [1: Introduction to HDL Coder](module-1-introduction) | Y = 2X + 5 in hand-written VHDL, Simulink and MATLAB | Yes | No |
| [2: Four-to-four switch](module-2-four-to-four-switch) | A switch built three ways, then run on the board with FPGA-in-the-loop | Yes | For FPGA-in-the-loop |
| [3: Multi-input adder](module-3-multi-adder) | Adding eight numbers with an adder tree, and checking its timing | Yes | No |
| [4: CRC-8 error locator](module-4-crc8-locator) | A controller and datapath that find a corrupted pixel in an image | No | No |
| [5: IIR filter](module-5-iir-filter) | Pipelining a filter's feedback loop, choosing word lengths, and running it on the board | Yes | Yes |
| [6: Board harness in Simulink](module-6-board-harness) | Module 5's board audio processing, moved out of VHDL and into Simulink | Yes | Yes |

## Setting up

You'll need Vivado and MATLAB. These modules use Vivado 2024.1, which works with MATLAB R2025a, R2025b and R2026a. The models were saved in R2024b, so any of those will open them.

Install these MATLAB add-ons:

- Simulink
- Fixed-Point Designer
- HDL Coder
- HDL Coder Support Package for Xilinx FPGA Boards
- HDL Verifier Support Package for AMD FPGA and SoC Devices (only needed for FPGA-in-the-loop in Module 2)

Modules 5 and 6 also use the Signal Processing Toolbox, and Module 6 needs the DSP System Toolbox too. If HDL Coder complains about a missing compiler when you use it with MATLAB code, install MATLAB Support for MinGW-w64 C/C++/Fortran Compiler.

Windows is the easiest option. Vivado doesn't run on macOS, so if you're on a Mac you'll need to use the lab computers, either in person or over RDP.

## The board

The hardware demos use a Digilent Nexys4, which has an Artix-7 FPGA (part `xc7a100tcsg324-1`). For Modules 5 and 6 you'll also want headphones or a speaker plugged into the audio jack.

If you have a Nexys4 DDR, the clock, audio and microphone pins are the same, but the switches, buttons and LEDs are on different pins. You'll need to change those in the Module 5 and 6 constraint files.

## How the folders are laid out

Change MATLAB's current folder to a module's folder before running anything in it, because the scripts look for their files there. MATLAB and Simulink files sit at the top of each module, and anything for Vivado (hand-written VHDL and constraint files) is in `vivado/src/`.
