

# Setting Design name and effort level for various stages
#-------------------------------------------------------------------------------
#set startTime [clock seconds]
set top_module    $DESIGN_NAME   ;# Top design name
set DC_VERILOG    "$SYN_PATH/${DESIGN_NAME}.synthesis.v"
set DC_SDC        "$SYN_PATH/${DESIGN_NAME}.synthesis.sdc"

# set DATE [clock format [clock seconds] -format "%b%d-%T"]
set OUTPUTS_PATH ./pnr_out            ;# Setting directory name for output
set OUTPUTS_SAVE ./pnr_save            ;# Setting directory name for output
set REPORTS_PATH ./pnr_reports        ;# Setting directory name for reports
set LOG_PATH     ./pnr_logs           ;# Setting directory name for logs


#-------------------------------------------------------------------------------
# Creating the directory for logs, reports and outputs
#-------------------------------------------------------------------------------
if {![file exists $LOG_PATH]} {
    file delete -force ${LOG_PATH}
}
if {![file exists $OUTPUTS_PATH]} {
    file delete -force ${OUTPUTS_PATH}
}
if {![file exists $REPORTS_PATH]} {
    file delete -force ${REPORTS_PATH}
}

file mkdir $LOG_PATH
file mkdir $OUTPUTS_PATH
file mkdir $OUTPUTS_SAVE
file mkdir $REPORTS_PATH

#-------------------------------------------------------------------------------
# Import the design
#-------------------------------------------------------------------------------
create_library_set -name slow_lib -timing $slow_lib
create_rc_corner -name slow_rc -cap_table $slow_rc
create_delay_corner -name slow -library_set slow_lib

create_constraint_mode -name sdc -sdc_files ${DC_SDC}
create_analysis_view -name slow -constraint_mode sdc -delay_corner slow

set init_lef_file $all_lef
set init_verilog $DC_VERILOG
set init_design_set_top 0

set init_pwr_net {VDD}
set init_gnd_net {VSS}

set density 0.15
init_design -setup slow -hold slow
floorPlan -site mc_site -r 1 $density 1500 1500 1500 1500
setPlaceMode -place_global_place_io_pins false
setDesignMode -topRoutingLayer 9 -bottomRoutingLayer 1
set_ccopt_property buffer_cells {BUFF}
set_ccopt_property inverter_cells {INV}
set_ccopt_property delay_cells {BUFF}
setPlaceMode -place_global_max_density $density
setOptMode -opt_max_density $density
setDistributeHost -local
setRouteMode -earlyGlobalHonorMsvRouteConstraint false -earlyGlobalRoutePartitionPinGuide true
setEndCapMode -reset
setEndCapMode -boundary_tap false
setNanoRouteMode -quiet -drouteAutoStop 0
setNanoRouteMode -quiet -drouteFixAntenna 0
setNanoRouteMode -quiet -droutePostRouteSwapVia {}
setNanoRouteMode -quiet -droutePostRouteSpreadWire 1
setNanoRouteMode -quiet -drouteUseMultiCutViaEffort {}
setNanoRouteMode -quiet -drouteOnGridOnly true
setNanoRouteMode -quiet -routeIgnoreAntennaTopCellPin 0
setNanoRouteMode -quiet -timingEngine {}
setUsefulSkewMode -noBoundary false -maxAllowedDelay 1
setPlaceMode -reset
setPlaceMode -congEffort auto -timingDriven 1 -clkGateAware 1 -powerDriven 0 -ignoreScan 1 -reorderScan 1 -ignoreSpare 0 -placeIOPins 0 -moduleAwareSpare 0 -maxDensity $density -checkPinLayerForAccess {  1 2 3 } -maxRouteLayer 9 -preserveRouting 1 -rmAffectedRouting 0 -checkRoute 0 -swapEEQ 0
setPlaceMode -fp false
