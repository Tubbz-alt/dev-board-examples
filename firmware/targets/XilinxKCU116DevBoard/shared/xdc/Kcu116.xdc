##############################################################################
## This file is part of 'Example Project Firmware'.
## It is subject to the license terms in the LICENSE.txt file found in the
## top-level directory of this distribution and at:
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
## No part of 'Example Project Firmware', including this file,
## may be copied, modified, propagated, or distributed except according to
## the terms contained in the LICENSE.txt file.
##############################################################################

set_property PACKAGE_PIN N5 [get_ports gtTxP[0]]
set_property PACKAGE_PIN N4 [get_ports gtTxN[0]]
set_property PACKAGE_PIN M2 [get_ports gtRxP[0]]
set_property PACKAGE_PIN M1 [get_ports gtRxN[0]]

set_property PACKAGE_PIN L5 [get_ports gtTxP[1]]
set_property PACKAGE_PIN L4 [get_ports gtTxN[1]]
set_property PACKAGE_PIN K2 [get_ports gtRxP[1]]
set_property PACKAGE_PIN K1 [get_ports gtRxN[1]]

set_property PACKAGE_PIN J5 [get_ports gtTxP[2]]
set_property PACKAGE_PIN J4 [get_ports gtTxN[2]]
set_property PACKAGE_PIN H2 [get_ports gtRxP[2]]
set_property PACKAGE_PIN H1 [get_ports gtRxN[2]]

set_property PACKAGE_PIN G5 [get_ports gtTxP[3]]
set_property PACKAGE_PIN G4 [get_ports gtTxN[3]]
set_property PACKAGE_PIN F2 [get_ports gtRxP[3]]
set_property PACKAGE_PIN F1 [get_ports gtRxN[3]]

set_property PACKAGE_PIN M7 [get_ports gtClkP]
set_property PACKAGE_PIN M6 [get_ports gtClkN]

set_property -dict { PACKAGE_PIN P14 IOSTANDARD ANALOG } [get_ports { vPIn }]
set_property -dict { PACKAGE_PIN R13 IOSTANDARD ANALOG } [get_ports { vNIn }]

set_property -dict { PACKAGE_PIN B9  IOSTANDARD LVCMOS33 } [get_ports { extRst }]

set_property -dict { PACKAGE_PIN C9  IOSTANDARD LVCMOS33 } [get_ports { led[0] }]
set_property -dict { PACKAGE_PIN D9  IOSTANDARD LVCMOS33 } [get_ports { led[1] }]
set_property -dict { PACKAGE_PIN E10 IOSTANDARD LVCMOS33 } [get_ports { led[2] }]
set_property -dict { PACKAGE_PIN E11 IOSTANDARD LVCMOS33 } [get_ports { led[3] }]
set_property -dict { PACKAGE_PIN F9  IOSTANDARD LVCMOS33 } [get_ports { led[4] }]
set_property -dict { PACKAGE_PIN F10 IOSTANDARD LVCMOS33 } [get_ports { led[5] }]
set_property -dict { PACKAGE_PIN G9  IOSTANDARD LVCMOS33 } [get_ports { led[6] }]
set_property -dict { PACKAGE_PIN G10 IOSTANDARD LVCMOS33 } [get_ports { led[7] }]

set_property -dict { PACKAGE_PIN AB14 IOSTANDARD LVCMOS33 } [get_ports { sfpTxDisL[0] }]
set_property -dict { PACKAGE_PIN AA14 IOSTANDARD LVCMOS33 } [get_ports { sfpTxDisL[1] }]
set_property -dict { PACKAGE_PIN AA15 IOSTANDARD LVCMOS33 } [get_ports { sfpTxDisL[2] }]
set_property -dict { PACKAGE_PIN Y15  IOSTANDARD LVCMOS33 } [get_ports { sfpTxDisL[3] }]

######################
# FLASH: Constraints #
######################

set_property -dict { PACKAGE_PIN U22 IOSTANDARD LVCMOS18 } [get_ports { flashCsL }]  ; # QSPI1_CS_B
set_property -dict { PACKAGE_PIN N23 IOSTANDARD LVCMOS18 } [get_ports { flashMosi }] ; # QSPI1_IO[0]
set_property -dict { PACKAGE_PIN P23 IOSTANDARD LVCMOS18 } [get_ports { flashMiso }] ; # QSPI1_IO[1]
set_property -dict { PACKAGE_PIN R20 IOSTANDARD LVCMOS18 } [get_ports { flashWp }]   ; # QSPI1_IO[2]
set_property -dict { PACKAGE_PIN R21 IOSTANDARD LVCMOS18 } [get_ports { flashHoldL }]; # QSPI1_IO[3]

set_property -dict { PACKAGE_PIN N21 IOSTANDARD LVCMOS18 } [get_ports { emcClk }]

######################
# Timing Constraints #
######################

create_clock -name gtClkP -period  6.400 [get_ports {gtClkP}]

create_generated_clock -name dnaClk [get_pins {U_App/U_Reg/U_AxiVersion/GEN_DEVICE_DNA.DeviceDna_1/GEN_ULTRA_SCALE.DeviceDnaUltraScale_Inst/BUFGCE_DIV_Inst/O}]

set_clock_groups -asynchronous -group [get_clocks {gtClkP}] -group [get_clocks {dnaClk}]
set_clock_groups -asynchronous -group [get_clocks gtClkP] -group [get_clocks -of_objects [get_pins U_App/U_Reg/U_AxiVersion/GEN_ICAP.Iprog_1/GEN_ULTRA_SCALE.IprogUltraScale_Inst/BUFGCE_DIV_Inst/O]]

######################################
# BITSTREAM: .bit file Configuration #
######################################
set_property CONFIG_VOLTAGE 1.8                      [current_design]
set_property CFGBVS GND                              [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE         [current_design]
set_property CONFIG_MODE SPIx8                       [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 8         [current_design]
set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN div-1 [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES      [current_design]
set_property BITSTREAM.CONFIG.UNUSEDPIN Pullup       [current_design]
set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR Yes     [current_design]
set_property BITSTREAM.STARTUP.LCK_CYCLE NoWait      [current_design]
set_property BITSTREAM.STARTUP.MATCH_CYCLE NoWait    [current_design]
