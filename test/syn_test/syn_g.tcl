setDesignMode -process 500
source mc_pdk.tcl
set DESIGN_NAME a
set SYN_PATH ./syn_out

set slow_lib      [list {pwd}/cells.lib]
set all_lef       [list {pwd}/tech.lef]
set slow_rc       [list {pwd}/cap.captable]
set tech_map_file [list {pwd}/tech.map]


set source [list a.v]
set toplevel a
set clock_period 1000

set_db max_cpus_per_server 8
set_db init_hdl_search_path ./
# if you have child modules, you need to add the paths of the other .lib files
set_db library [list $slow_lib]
set_db interconnect_mode wireload

# read in sources
read_hdl -language sv $sources

# elaborate
elaborate $toplevel

# constraints
create_clock -name clk -period $clock_period clock

# uncomment this if you want retiming
# set_db design:$toplevel .retime true

syn_generic
syn_map
syn_opt
