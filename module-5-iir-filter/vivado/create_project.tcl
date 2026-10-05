# Creates nexys4_iir.xpr. Run step6_board.m first: the filter VHDL is read
# from ../work/hdlsrc, where HDL Coder puts it.
# In the Vivado Tcl console: cd to this folder, then  source create_project.tcl
set here [file dirname [file normalize [info script]]]
cd $here

create_project -force nexys4_iir $here -part xc7a100tcsg324-1
add_files [glob src/*.vhd ../work/hdlsrc/iir_pipelined/*.vhd]
remove_files [list src/tb_nexys4_top.vhd]
add_files -fileset constrs_1 src/nexys4.xdc
add_files -fileset sim_1 src/tb_nexys4_top.vhd
set_property top nexys4_top [current_fileset]
set_property top tb_nexys4_top [get_filesets sim_1]
set_property STEPS.SYNTH_DESIGN.ARGS.MAX_DSP 0 [get_runs synth_1]   ;# multipliers in LUTs
close_project
