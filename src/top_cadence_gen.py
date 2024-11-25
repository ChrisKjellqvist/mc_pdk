import os
from pathlib import Path

import tcl.genus.gen_imp as gi
import tcl.genus.gen_syn as gs
import sys

if __name__ == "__main__":
    if not Path(os.getcwd() + "/run").is_dir():
        os.makedirs(os.getcwd() + "/run")
    gs.gen_syn_for_top(sys.argv[0])
    gi.gen_imp()
