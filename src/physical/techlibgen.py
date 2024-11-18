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
""")

    with open("")