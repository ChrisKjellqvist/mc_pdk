import src.libgen.cell as c
from src.global_constants import *


def get_via_lef(i):
    return f"""
LAYER VIA{i}
    TYPE CUT ;
    SPACING {wire_spacing} ;
    PROPERTY LEF57_SPACING "SPACING {wire_spacing} PARALLELOVERLAP ;" ;
END VIA{i}
"""


def get_layer_lef(i):
    return f"""
LAYER M{i}
    TYPE ROUTING ;
    DIRECTION {"HORIZONTAL" if i % 2 == 1 else "VERTICAL"} ;
    PITCH {pitch} ;
    WIDTH {wire_width} ;
    SPACING {wire_spacing} ;
    AREA {wire_width*placement_grid_size} ; # 1xmin_space wire is minarea (signifying a dot - needed for vias)

    PROPERTY LEF57_SPACING "SPACING {wire_spacing} ENDOFLINE {wire_spacing} WITHIN {wire_width} PARALLELEDGE {wire_spacing} WITHIN {wire_spacing} ;" ;
END M{i}
"""


def get_via_def_between(i, j):
    assert(i + 1 == j)
    return f"""
VIA VIA{i}{j} DEFAULT
    LAYER M{j} ;
        RECT -{wire_width/2} -{wire_width/2} {wire_width/2} {wire_width/2} ;
    LAYER VIA{i} ;
        RECT -{wire_width/2} -{wire_width/2} {wire_width/2} {wire_width/2} ;
    LAYER M{i} ;
        RECT -{wire_width/2} -{wire_width/2} {wire_width/2} {wire_width/2} ;
END VIA{i}{j}
"""

def export_lef(n_layers, ofile):
    to_write = f"""VERSION 5.6 ;
BUSBITCHARS "[]" ;
DIVIDERCHAR "/" ;

UNITS
    DATABASE MICRONS 100 ;
END UNITS

MANUFACTURINGGRID {manufacturing_grid_size} ;
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
    to_write += f"""
SITE mc_site
    SIZE {placement_grid_size} BY {placement_grid_size*5} ;
    CLASS CORE ;
    SYMMETRY X ;
END mc_site
"""
    for cell in c.cells:
        to_write += cell.layout.cell2lefabstract(cell.name, cell.ipins)
    to_write += "END LIBRARY\n"
    with open(ofile, 'w') as f:
        f.write(to_write)

