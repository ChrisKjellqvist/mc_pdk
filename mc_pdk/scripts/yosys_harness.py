import subprocess as sp


def synthesize(f_in: str,
               f_out: str,
               lib: str,
               top: str):
    """
    Synthesize the given file using the given library
    :param f: file to synthesize
    :param lib: library to use
    :return: None
    """
    sp.run(["yosys",
            "-p",
            f"read_verilog {f_in}; "
            f"hierarchy -check -top {top}; "
            f"proc; "
            f"opt; "
            f"techmap; "
            f"abc -liberty {lib}; "
            f"write_verilog {f_out}"])


if __name__ == "__main__":
    synthesize("test/test.v", "test/test_syn.v", "cells.lib", "top")
