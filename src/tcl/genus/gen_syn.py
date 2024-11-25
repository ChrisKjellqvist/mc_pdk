import os


def gen_syn_for_top(top: str, ifile: str, clock_pin: str):
    with open(os.getcwd() + "/run/0_syn_genus.tcl", 'w') as f:
        f.write(f"""
source {os.getcwd()}/pdk_gen/techfile.tcl
set_db max_cpus_per_server 8
set_db init_hdl_search_path ./
# if you have child modules, you need to add the paths of the other .lib files
set_db library [list $slow_lib]
set_db interconnect_mode wireload

# read in sources
read_hdl -language sv "{ifile}.v"

set toplevel {top}
# elaborate
elaborate $toplevel

# constraints. set clock to whatever. time units is ticks
set clock_period 25
create_clock -name clk -period $clock_period {clock_pin}

# make sure you add input and output delays
# set_input_delay -clock clk 1 [get_object_name [get_ports -filter direction==in io*]]
# set_output_delay -clock clk 1 [get_object_name [get_ports -filter direction==out io*]]

# uncomment this if you want retiming
set_db design:$toplevel .retime true

# synthesis steps!
#syn_generic
#syn_map
#syn_opt

# report_area -detail > area.rpt
# report_timing > timing.rpt
# 
# write_sdc > syn_out/$toplevel.synthesis.sdc
# write_hdl > syn_out/$toplevel.synthesis.v
""")