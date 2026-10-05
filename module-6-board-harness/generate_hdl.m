%% Generate VHDL for the board
iir_setup

%% microphone decimator
load_system('mic_decimator');
makehdl('mic_decimator', 'TargetDirectory', 'work/hdlsrc');

%% audio processing, including the pipelined filter
load_system('board_audio');
makehdl('board_audio', 'TargetDirectory', 'work/hdlsrc');

% then run vivado/create_project.tcl (first time only), open vivado/nexys4_iir.xpr
% and click Generate Bitstream.
