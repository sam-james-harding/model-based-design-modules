%% Step 6: generate VHDL for the board
iir_setup

%% generate VHDL for the pipelined filter
load_system('iir_pipelined');
makehdl('iir_pipelined', 'TargetDirectory', 'work/hdlsrc');

% then run vivado/create_project.tcl (first time only), open vivado/nexys4_iir.xpr
% and click Generate Bitstream
