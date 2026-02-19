## =========================================================
## Basys 3 (xc7a35tcpg236-1) constraints for top_ps2_pcm
## Ports used:
## clk, rst, ps2_clk, ps2_dat, aud,
## a,b,c,d,e,f,g, dp, an0..an3
## =========================================================

## 100 MHz system clock
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

## Reset button (Center)
set_property PACKAGE_PIN U18 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]

## -------------------------
## 7-segment display
## Basys3 mapping:
## seg[0]=CA(W7), seg[1]=CB(W6), seg[2]=CC(U8),
## seg[3]=CD(V8), seg[4]=CE(U5), seg[5]=CF(V5), seg[6]=CG(U7)
## dp=V7, an[0]=U2, an[1]=U4, an[2]=V4, an[3]=W4
## -------------------------

## segments a..g (your ports are a,b,c,d,e,f,g)
set_property PACKAGE_PIN W7 [get_ports a]
set_property PACKAGE_PIN W6 [get_ports b]
set_property PACKAGE_PIN U8 [get_ports c]
set_property PACKAGE_PIN V8 [get_ports d]
set_property PACKAGE_PIN U5 [get_ports e]
set_property PACKAGE_PIN V5 [get_ports f]
set_property PACKAGE_PIN U7 [get_ports g]

set_property IOSTANDARD LVCMOS33 [get_ports {a b c d e f g}]

## decimal point
set_property PACKAGE_PIN V7 [get_ports dp]
set_property IOSTANDARD LVCMOS33 [get_ports dp]

## anodes an0..an3 (active-low on Basys3)
set_property PACKAGE_PIN U2 [get_ports an0]
set_property PACKAGE_PIN U4 [get_ports an1]
set_property PACKAGE_PIN V4 [get_ports an2]
set_property PACKAGE_PIN W4 [get_ports an3]
set_property IOSTANDARD LVCMOS33 [get_ports {an0 an1 an2 an3}]

## -------------------------
## PS/2 via USB-HID (onboard)
## Note: Basys3 requires internal pullups for PS/2 lines
## -------------------------
set_property PACKAGE_PIN C17 [get_ports ps2_clk]
set_property IOSTANDARD LVCMOS33 [get_ports ps2_clk]
set_property PULLUP true [get_ports ps2_clk]

set_property PACKAGE_PIN B17 [get_ports ps2_dat]
set_property IOSTANDARD LVCMOS33 [get_ports ps2_dat]
set_property PULLUP true [get_ports ps2_dat]

## -------------------------
## Audio output
## Basys3 has no dedicated audio-out pin; use a Pmod pin.
## This maps aud to JA1 (J1). Connect buzzer/speaker module:
## JA1 = signal, any GND pin = ground.
## -------------------------
set_property PACKAGE_PIN J1 [get_ports aud]
set_property IOSTANDARD LVCMOS33 [get_ports aud]