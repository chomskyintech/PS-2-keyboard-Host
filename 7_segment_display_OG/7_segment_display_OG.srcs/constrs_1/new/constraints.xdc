# Constraints for CLK
set_property PACKAGE_PIN W5 [get_ports {clk}]
set_property IOSTANDARD LVCMOS33 [get_ports {clk}]
create_clock -name external_clock -period 10.00 [get_ports {clk}]
# Constraints for SW0
set_property PACKAGE_PIN V17 [get_ports {val0[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {val0[0]}]
# Constraints for SW1
set_property PACKAGE_PIN V16 [get_ports {val0[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {val0[1]}]
# Constraints for SW2
set_property PACKAGE_PIN W16 [get_ports {val0[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {val0[2]}]
# Constraints for SW3
set_property PACKAGE_PIN W17 [get_ports {val0[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {val0[3]}]
# Constraints for BTNU
set_property PACKAGE_PIN T18 [get_ports dot0]
set_property IOSTANDARD LVCMOS33 [get_ports dot0]
# Constraints for SW4
set_property PACKAGE_PIN W15 [get_ports {val1[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {val1[0]}]
# Constraints for SW5
set_property PACKAGE_PIN V15 [get_ports {val1[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {val1[1]}]
# Constraints for SW6
set_property PACKAGE_PIN W14 [get_ports {val1[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {val1[2]}]
# Constraints for SW7
set_property PACKAGE_PIN W13 [get_ports {val1[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {val1[3]}]
# Constraints for BTNR
set_property PACKAGE_PIN T17 [get_ports dot1]
set_property IOSTANDARD LVCMOS33 [get_ports dot1]
# Constraints for SW8
set_property PACKAGE_PIN V2 [get_ports {val2[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {val2[0]}]
# Constraints for SW9
set_property PACKAGE_PIN T3 [get_ports {val2[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {val2[1]}]
# Constraints for SW10
set_property PACKAGE_PIN T2 [get_ports {val2[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {val2[2]}]
# Constraints for SW11
set_property PACKAGE_PIN R3 [get_ports {val2[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {val2[3]}]
# Constraints for BTND
set_property PACKAGE_PIN U17 [get_ports dot2]
set_property IOSTANDARD LVCMOS33 [get_ports dot2]
# Constraints for SW12
set_property PACKAGE_PIN W2 [get_ports {val3[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {val3[0]}]
# Constraints for SW13
set_property PACKAGE_PIN U1 [get_ports {val3[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {val3[1]}]
# Constraints for SW14
set_property PACKAGE_PIN T1 [get_ports {val3[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {val3[2]}]
# Constraints for SW15
set_property PACKAGE_PIN R2 [get_ports {val3[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {val3[3]}]
# Constraints for BTNL
set_property PACKAGE_PIN W19 [get_ports dot3]
set_property IOSTANDARD LVCMOS33 [get_ports dot3]
# Constraints for A
set_property PACKAGE_PIN W7 [get_ports {a}]
set_property IOSTANDARD LVCMOS33 [get_ports {a}]
# Constraints for B
set_property PACKAGE_PIN W6 [get_ports {b}]
set_property IOSTANDARD LVCMOS33 [get_ports {b}]
# Constraints for C
set_property PACKAGE_PIN U8 [get_ports {c}]
set_property IOSTANDARD LVCMOS33 [get_ports {c}]
# Constraints for D
set_property PACKAGE_PIN V8 [get_ports {d}]
set_property IOSTANDARD LVCMOS33 [get_ports {d}]
# Constraints for E
set_property PACKAGE_PIN U5 [get_ports {e}]
set_property IOSTANDARD LVCMOS33 [get_ports {e}]
# Constraints for F
set_property PACKAGE_PIN V5 [get_ports {f}]
set_property IOSTANDARD LVCMOS33 [get_ports {f}]
# Constraints for G
set_property PACKAGE_PIN U7 [get_ports {g}]
set_property IOSTANDARD LVCMOS33 [get_ports {g}]
# Constraints for DP
set_property PACKAGE_PIN V7 [get_ports dp]
set_property IOSTANDARD LVCMOS33 [get_ports dp]
# Constraints for AN0
set_property PACKAGE_PIN U2 [get_ports {an0}]
set_property IOSTANDARD LVCMOS33 [get_ports {an0}]
# Constraints for AN1
set_property PACKAGE_PIN U4 [get_ports {an1}]
set_property IOSTANDARD LVCMOS33 [get_ports {an1}]
# Constraints for AN2
set_property PACKAGE_PIN V4 [get_ports {an2}]
set_property IOSTANDARD LVCMOS33 [get_ports {an2}]
# Constraints for AN3
set_property PACKAGE_PIN W4 [get_ports {an3}]
set_property IOSTANDARD LVCMOS33 [get_ports {an3}]
# Constraints for CFGBVS
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
# Reset (BTNC)
set_property PACKAGE_PIN U18 [get_ports rs]
set_property IOSTANDARD LVCMOS33 [get_ports rs]