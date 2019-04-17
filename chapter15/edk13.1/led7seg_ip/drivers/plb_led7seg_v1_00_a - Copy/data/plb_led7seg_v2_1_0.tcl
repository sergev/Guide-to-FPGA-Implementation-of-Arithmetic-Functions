##############################################################################
## Filename:          plb_led7seg_v2_1_0.tcl
## Description:       Microprocess Driver Command (tcl)
## Date:              (by Create and Import Peripheral Wizard)
##############################################################################

#uses "xillib.tcl"

proc generate {drv_handle} {
  xdefine_include_file $drv_handle "xparameters.h" "plb_led7seg" "NUM_INSTANCES" "DEVICE_ID" "C_BASEADDR" "C_HIGHADDR" 
}
