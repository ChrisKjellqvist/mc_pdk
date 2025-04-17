from typing import *
from mc_pdk.libgen import cell as c
from mc_pdk.libgen.lefgen import export_lef
from mc_pdk.libgen.capgen import gen_cap
from mc_pdk.libgen.mapgen import gen_map
from mc_pdk.cells import logic as tl
import mc_pdk.cells.sequential as ts
import mc_pdk.tcl.techfile as tech

if __name__ == "__main__":
    c.init_cells()
    tl.declare_logical_cells()
    ts.declare_sequential_cells()
    c.export_lib(ofile="./pdk_gen/cells.lib")
    export_lef(n_layers=9,
               ofile="./pdk_gen/tech.lef")
    gen_cap(n_layers=9,
            ofile="./pdk_gen/cap.captable")
    gen_map(n_layers=9,
            ofile="./pdk_gen/tech.map")
    tech.gen_techfile(ofile="./pdk_gen/techfile.tcl")

