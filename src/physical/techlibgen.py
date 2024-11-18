import os

def gen_techlib():
    pwd = os.getcwd()
    with open("mc_pdk.tcl", 'w') as f:
        f.write(f"set slow_lib      [list {pwd}/cells.lib]\n"
                f"set all_lef       [list {pwd}/tech.lef]\n"
                f"set slow_rc       [list {pwd}/cap.captable]\n"
                f"set tech_map_file [list {pwd}/tech.map]\n")


def gen_gscripts(top_name):
    with open("syn_g.tcl", 'w') as f:
        f.write(f"""
setDesignMode -process 500
source mc_pdk.tcl
set DESIGN_NAME {top_name}
set SYN_PATH ./syn_out

source mc_pdk.tcl

set_db max_cpus_per_server 8
set_db init_hdl_search_path ../../src
# if you have child modules, you need to add the paths of the other .lib files
set_db library [list $slow_lib]
set_db interconnect_mode wireload
""")