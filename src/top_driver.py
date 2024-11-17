from src.liberty import cell as c
from src.physical.lefgen import export_lef
from src.physical.capgen import gen_cap
from src.physical.mapgen import gen_map
import top_logic as tl
import top_sequential as ts

if __name__ == "__main__":
    c.init_cells()
    tl.declare_logical_cells()
    ts.declare_sequential_cells()
    c.export_lib()
    export_lef(n_layers=9)
    gen_cap(n_layers=9,
            ofile="cap.captable")
    gen_map(n_layers=9,
            ofile="tech.map")
