import os


def gen_imp():
    home = os.getcwd()
    with open(home + "/run/1_setup.tcl", 'w') as f:
        f.write(f"""
setDesignMode -process 65
source {home}/pdk_gen/
set DESIGN_NAME SystolicArray_4x1024x8x5
set SYN_PATH {home}/run/syn_out/
""")
    with open(home + "/run/2_init.tcl", 'w') as f:
        f.write(f"""
#-------------------------------------------------------------------------------
# Setting Design name and effort level for various stages
#-------------------------------------------------------------------------------
#set startTime [clock seconds]
set top_module    $DESIGN_NAME   ;# Top design name
set DC_VERILOG    "$SYN_PATH/${{DESIGN_NAME}}.synthesis.v"
set DC_SDC        "$SYN_PATH/${{DESIGN_NAME}}.synthesis.sdc"

# set DATE [clock format [clock seconds] -format "%b%d-%T"]
set OUTPUTS_PATH ./pnr_out            ;# Setting directory name for output
set OUTPUTS_SAVE ./pnr_save            ;# Setting directory name for output
set REPORTS_PATH ./pnr_reports        ;# Setting directory name for reports
set LOG_PATH     ./pnr_logs           ;# Setting directory name for logs


#-------------------------------------------------------------------------------
# Creating the directory for logs, reports and outputs
#-------------------------------------------------------------------------------
if {{![file exists $LOG_PATH]}} {{
    file delete -force ${{LOG_PATH}}
}}
if {{![file exists $OUTPUTS_PATH]}} {{
    file delete -force ${{OUTPUTS_PATH}}
}}
if {{![file exists $REPORTS_PATH]}} {{
    file delete -force ${{REPORTS_PATH}}
}}

file mkdir $LOG_PATH
file mkdir $OUTPUTS_PATH
file mkdir $OUTPUTS_SAVE
file mkdir $REPORTS_PATH

#-------------------------------------------------------------------------------
# Import the design
#-------------------------------------------------------------------------------
create_library_set -name slow_lib -timing $slow_lib
create_rc_corner -name slow_rc -cap_table $slow_rc

create_constraint_mode -name sdc -sdc_files ${{DC_SDC}}
create_analysis_view -name slow -constraint_mode sdc -delay_corner slow
create_analysis_view -name fast -constraint_mode sdc -delay_corner fast

set init_lef_file $all_lef
set init_verilog $DC_VERILOG
set init_design_set_top 0

set init_pwr_net {{VDD}}
set init_gnd_net {{VSS}}

init_design -setup slow -hold fast
""")
