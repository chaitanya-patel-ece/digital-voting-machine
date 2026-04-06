## ============================================================
## Digital Voting Machine with Party Selection
## Basys 3 Constraints File (.xdc)
## Board: Digilent Basys 3 (Artix-7 XC7A35T-1CPG236C)
## ============================================================

## ============================================================
## CLOCK — 100 MHz onboard oscillator
## ============================================================
set_property PACKAGE_PIN W5       [get_ports clk]
set_property IOSTANDARD  LVCMOS33 [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

## ============================================================
## SWITCHES
## SW[0] = Select Candidate 1  (within current party)
## SW[1] = Select Candidate 2  (within current party)
## (Only one switch ON at a time is valid)
## ============================================================
set_property PACKAGE_PIN V17      [get_ports {sw[0]}]
set_property IOSTANDARD  LVCMOS33 [get_ports {sw[0]}]

set_property PACKAGE_PIN V16      [get_ports {sw[1]}]
set_property IOSTANDARD  LVCMOS33 [get_ports {sw[1]}]

## ============================================================
## PUSH BUTTONS
## BTNC (Center) = Cast Vote
## BTNL (Left)   = Cycle Result Display
## BTNR (Right)  = Reset All Votes
## BTNU (Up)     = Party SELECT UP  (P1 -> P2 -> P3 -> P1)
## BTND (Down)   = Party SELECT DOWN(P1 -> P3 -> P2 -> P1)
## ============================================================
set_property PACKAGE_PIN U18      [get_ports btnC]
set_property IOSTANDARD  LVCMOS33 [get_ports btnC]

set_property PACKAGE_PIN W19      [get_ports btnL]
set_property IOSTANDARD  LVCMOS33 [get_ports btnL]

set_property PACKAGE_PIN T17      [get_ports btnR]
set_property IOSTANDARD  LVCMOS33 [get_ports btnR]

set_property PACKAGE_PIN T18      [get_ports btnU]
set_property IOSTANDARD  LVCMOS33 [get_ports btnU]

set_property PACKAGE_PIN U17      [get_ports btnD]
set_property IOSTANDARD  LVCMOS33 [get_ports btnD]

## ============================================================
## 7-SEGMENT DISPLAY — Cathodes (active low)
## seg[0]=CA  seg[1]=CB  seg[2]=CC  seg[3]=CD
## seg[4]=CE  seg[5]=CF  seg[6]=CG
## ============================================================
set_property PACKAGE_PIN W7       [get_ports {seg[0]}]
set_property IOSTANDARD  LVCMOS33 [get_ports {seg[0]}]

set_property PACKAGE_PIN W6       [get_ports {seg[1]}]
set_property IOSTANDARD  LVCMOS33 [get_ports {seg[1]}]

set_property PACKAGE_PIN U8       [get_ports {seg[2]}]
set_property IOSTANDARD  LVCMOS33 [get_ports {seg[2]}]

set_property PACKAGE_PIN V8       [get_ports {seg[3]}]
set_property IOSTANDARD  LVCMOS33 [get_ports {seg[3]}]

set_property PACKAGE_PIN U5       [get_ports {seg[4]}]
set_property IOSTANDARD  LVCMOS33 [get_ports {seg[4]}]

set_property PACKAGE_PIN V5       [get_ports {seg[5]}]
set_property IOSTANDARD  LVCMOS33 [get_ports {seg[5]}]

set_property PACKAGE_PIN U7       [get_ports {seg[6]}]
set_property IOSTANDARD  LVCMOS33 [get_ports {seg[6]}]

## ============================================================
## 7-SEGMENT DISPLAY — Anodes (active low, digit select)
## an[0]=AN0 rightmost   an[3]=AN3 leftmost
## ============================================================
set_property PACKAGE_PIN U2       [get_ports {an[0]}]
set_property IOSTANDARD  LVCMOS33 [get_ports {an[0]}]

set_property PACKAGE_PIN U4       [get_ports {an[1]}]
set_property IOSTANDARD  LVCMOS33 [get_ports {an[1]}]

set_property PACKAGE_PIN V4       [get_ports {an[2]}]
set_property IOSTANDARD  LVCMOS33 [get_ports {an[2]}]

set_property PACKAGE_PIN W4       [get_ports {an[3]}]
set_property IOSTANDARD  LVCMOS33 [get_ports {an[3]}]

## ============================================================
## DECIMAL POINT
## ============================================================
set_property PACKAGE_PIN V7       [get_ports dp]
set_property IOSTANDARD  LVCMOS33 [get_ports dp]

## ============================================================
## LEDs
## LED[0]  = Party 1 selected
## LED[1]  = Party 2 selected
## LED[2]  = Party 3 selected
## LED[3]  = Candidate 1 selected
## LED[4]  = Candidate 2 selected
## LED[5..12] = unused (tied low in RTL)
## LED[13] = Result mode active
## LED[14] = Invalid vote warning
## LED[15] = Vote accepted flash
## ============================================================
set_property PACKAGE_PIN U16      [get_ports {led[0]}]
set_property IOSTANDARD  LVCMOS33 [get_ports {led[0]}]

set_property PACKAGE_PIN E19      [get_ports {led[1]}]
set_property IOSTANDARD  LVCMOS33 [get_ports {led[1]}]

set_property PACKAGE_PIN U19      [get_ports {led[2]}]
set_property IOSTANDARD  LVCMOS33 [get_ports {led[2]}]

set_property PACKAGE_PIN V19      [get_ports {led[3]}]
set_property IOSTANDARD  LVCMOS33 [get_ports {led[3]}]

set_property PACKAGE_PIN W18      [get_ports {led[4]}]
set_property IOSTANDARD  LVCMOS33 [get_ports {led[4]}]

set_property PACKAGE_PIN U15      [get_ports {led[5]}]
set_property IOSTANDARD  LVCMOS33 [get_ports {led[5]}]

set_property PACKAGE_PIN U14      [get_ports {led[6]}]
set_property IOSTANDARD  LVCMOS33 [get_ports {led[6]}]

set_property PACKAGE_PIN V14      [get_ports {led[7]}]
set_property IOSTANDARD  LVCMOS33 [get_ports {led[7]}]

set_property PACKAGE_PIN V13      [get_ports {led[8]}]
set_property IOSTANDARD  LVCMOS33 [get_ports {led[8]}]

set_property PACKAGE_PIN V3       [get_ports {led[9]}]
set_property IOSTANDARD  LVCMOS33 [get_ports {led[9]}]

set_property PACKAGE_PIN W3       [get_ports {led[10]}]
set_property IOSTANDARD  LVCMOS33 [get_ports {led[10]}]

set_property PACKAGE_PIN U3       [get_ports {led[11]}]
set_property IOSTANDARD  LVCMOS33 [get_ports {led[11]}]

set_property PACKAGE_PIN P3       [get_ports {led[12]}]
set_property IOSTANDARD  LVCMOS33 [get_ports {led[12]}]

set_property PACKAGE_PIN N3       [get_ports {led[13]}]
set_property IOSTANDARD  LVCMOS33 [get_ports {led[13]}]

set_property PACKAGE_PIN P1       [get_ports {led[14]}]
set_property IOSTANDARD  LVCMOS33 [get_ports {led[14]}]

set_property PACKAGE_PIN L1       [get_ports {led[15]}]
set_property IOSTANDARD  LVCMOS33 [get_ports {led[15]}]

## ============================================================
## Configuration Settings
## ============================================================
set_property CFGBVS         VCCO  [current_design]
set_property CONFIG_VOLTAGE 3.3   [current_design]
