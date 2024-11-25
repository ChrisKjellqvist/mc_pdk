from enum import Enum
import src.liberty.cell as c
from src.global_constants import *
import src.liberty.grammar
from src.liberty.grammar import alphabet_input, alphabet_output
import src.liberty.layout as layout


def get_via_lef(i):
    return f"""
LAYER VIA{i}
    TYPE CUT ;
    SPACING {min_spacing} ;
    PROPERTY LEF57_SPACING "SPACING {min_spacing} PARALLELOVERLAP ;" ;
END VIA{i}
"""


def get_layer_lef(i):
    return f"""
LAYER M{i}
    TYPE ROUTING ;
    DIRECTION {"HORIZONTAL" if i % 2 == 1 else "VERTICAL"} ;
    PITCH {grid_size} ;
    WIDTH 1 ;
    SPACING {min_spacing} ;
    AREA {min_spacing} ; # 1xmin_space wire is minarea (signifying a dot - needed for vias)

    PROPERTY LEF57_SPACING "SPACING {min_spacing} ENDOFLINE {grid_size} WITHIN {grid_size} PARALLELEDGE {grid_size} WITHIN {grid_size} ;" ;
END M{i}
"""


def get_via_def_between(i, j):
    assert(i + 1 == j)
    return f"""
VIA VIA{i}{j} DEFAULT
    LAYER M{j} ;
        RECT -1 -1.5 1 1.5 ;
    LAYER VIA{i} ;
        RECT -1 -1 1 1 ;
    LAYER M{i} ;
        RECT -1 -1.5 1 1.5 ;
END VIA{i}{j}
"""

def get_viarule_between(i, j):
    return f"""
"""


def export_lef(n_layers, ofile):
    to_write = f"""VERSION 5.6 ;
BUSBITCHARS "[]" ;
DIVIDERCHAR "/" ;

UNITS
    DATABASE MICRONS 100 ;
END UNITS

MANUFACTURINGGRID 0.01 ;
PROPERTYDEFINITIONS
    LAYER LEF57_SPACING STRING ;
    LAYER LEF57_MINSTEP STRING ;
END PROPERTYDEFINITIONS
"""

    for i in range(1, n_layers + 1):
        to_write += get_layer_lef(i)
        if i != n_layers:
            to_write += get_via_lef(i)
    for i in range(1, n_layers):
        to_write += get_via_def_between(i, i+1)
    # for i in range(1, n_layers):
    #     to_write += get_viarule_between(i, i+1)
    to_write += """
SITE mc_site
    SIZE 1 BY 1 ;
    CLASS CORE ;
    SYMMETRY Y ;
END mc_site
"""
    for cell in c.cells:
        to_write += cell.layout.cell2lefabstract(cell.name, cell.ipins)
    to_write += "END LIBRARY\n"
    with open(ofile, 'w') as f:
        f.write(to_write)

