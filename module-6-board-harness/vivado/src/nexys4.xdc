## Nexys4 pins (from the Digilent master XDC). A Nexys4 DDR has the same audio,
## microphone, clock and reset pins, but different switch, button and LED pins.
set_property -dict {PACKAGE_PIN E3  IOSTANDARD LVCMOS33} [get_ports CLK100MHZ]
set_property -dict {PACKAGE_PIN C12 IOSTANDARD LVCMOS33} [get_ports CPU_RESETN]
set_property -dict {PACKAGE_PIN J5  IOSTANDARD LVCMOS33} [get_ports M_CLK]
set_property -dict {PACKAGE_PIN H5  IOSTANDARD LVCMOS33} [get_ports M_DATA]
set_property -dict {PACKAGE_PIN F5  IOSTANDARD LVCMOS33} [get_ports M_LRSEL]
set_property -dict {PACKAGE_PIN A11 IOSTANDARD LVCMOS33} [get_ports AUD_PWM]
set_property -dict {PACKAGE_PIN D12 IOSTANDARD LVCMOS33} [get_ports AUD_SD]

set_property -dict {PACKAGE_PIN E16 IOSTANDARD LVCMOS33} [get_ports BTNC]
set_property -dict {PACKAGE_PIN U9  IOSTANDARD LVCMOS33} [get_ports {SW[0]}]
set_property -dict {PACKAGE_PIN U8  IOSTANDARD LVCMOS33} [get_ports {SW[1]}]

set_property -dict {PACKAGE_PIN T8  IOSTANDARD LVCMOS33} [get_ports {LED[0]}]
set_property -dict {PACKAGE_PIN V9  IOSTANDARD LVCMOS33} [get_ports {LED[1]}]
set_property -dict {PACKAGE_PIN R8  IOSTANDARD LVCMOS33} [get_ports {LED[2]}]
set_property -dict {PACKAGE_PIN T6  IOSTANDARD LVCMOS33} [get_ports {LED[3]}]
set_property -dict {PACKAGE_PIN T5  IOSTANDARD LVCMOS33} [get_ports {LED[4]}]
set_property -dict {PACKAGE_PIN T4  IOSTANDARD LVCMOS33} [get_ports {LED[5]}]
set_property -dict {PACKAGE_PIN U7  IOSTANDARD LVCMOS33} [get_ports {LED[6]}]
set_property -dict {PACKAGE_PIN U6  IOSTANDARD LVCMOS33} [get_ports {LED[7]}]
set_property -dict {PACKAGE_PIN V4  IOSTANDARD LVCMOS33} [get_ports {LED[8]}]
set_property -dict {PACKAGE_PIN U3  IOSTANDARD LVCMOS33} [get_ports {LED[9]}]
set_property -dict {PACKAGE_PIN V1  IOSTANDARD LVCMOS33} [get_ports {LED[10]}]
set_property -dict {PACKAGE_PIN R1  IOSTANDARD LVCMOS33} [get_ports {LED[11]}]
set_property -dict {PACKAGE_PIN P5  IOSTANDARD LVCMOS33} [get_ports {LED[12]}]
set_property -dict {PACKAGE_PIN U1  IOSTANDARD LVCMOS33} [get_ports {LED[13]}]
set_property -dict {PACKAGE_PIN R2  IOSTANDARD LVCMOS33} [get_ports {LED[14]}]
set_property -dict {PACKAGE_PIN P2  IOSTANDARD LVCMOS33} [get_ports {LED[15]}]

set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

create_clock -name sys_clk -period 10.000 [get_ports CLK100MHZ]

## Buttons, switches and audio pins are slow compared with the clock
set_false_path -from [get_ports {CPU_RESETN BTNC SW[*] M_DATA}]
set_false_path -to   [get_ports {LED[*] M_CLK M_LRSEL AUD_PWM AUD_SD}]
