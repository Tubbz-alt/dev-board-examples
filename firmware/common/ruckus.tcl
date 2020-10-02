# Load RUCKUS library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load the Core
loadRuckusTcl "$::DIR_PATH/core"
loadRuckusTcl "$::DIR_PATH/VivadoHls"

# Get the family type
set family [getFpgaFamily]

if { ${family} eq {artix7}  ||
     ${family} eq {kintex7} ||
     ${family} eq {virtex7} ||
     ${family} eq {zynq} } {
   loadRuckusTcl "$::DIR_PATH/7Series"
}

if { ${family} eq {kintexu} } {
   loadRuckusTcl "$::DIR_PATH/UltraScale"
}

if { ${family} eq {kintexuplus} ||
     ${family} eq {virtexuplus} ||
     ${family} eq {virtexuplusHBM} ||
     ${family} eq {zynquplus} ||
     ${family} eq {zynquplusRFSOC} ||
     ${family} eq {qzynquplusRFSOC} } {
   loadRuckusTcl "$::DIR_PATH/UltraScale"
}
