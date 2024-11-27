import os
from pathlib import Path

import tcl.genus.gen_imp as gi
import tcl.genus.gen_syn as gs

if __name__ == "__main__":
    ifile = input("name of your input_file (.v): \n").strip()
    top_model = input("name of your top-module: \n").strip()
    clock_pin = input("name of your clock pin: \n").strip()
    if not Path(os.getcwd() + "/run").is_dir():
        os.makedirs(os.getcwd() + "/run")
    gs.gen_syn_for_top(top_model, ifile, clock_pin)
    gi.gen_imp(top_model)
