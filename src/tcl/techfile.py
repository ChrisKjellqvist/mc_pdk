import os


def gen_techfile(ofile):
    home = os.getcwd()
    with open(ofile, 'w') as f:
        f.write(f"""set STDLIB_DIR {home}/pdk_gen
        
set slow_lib [list {home}/pdk_gen/cells.lib]
set fast_lib $slow_lib

set all_lef [list {home}/pdk_gen/tech.lef]

set slow_rc {home}/pdk_gen/cap.captable
set fast_rc $slow_rc

set tech_map_file {home}/pdk_gen/tech.map
""")

