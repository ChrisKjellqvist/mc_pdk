from numpy.lib.function_base import place

import mc_pdk.libgen.cell as c
from mc_pdk.global_constants import *


def get_via_lef(i):
    return f"""
LAYER VIA{i}
    TYPE CUT ;
    SPACING {wire_spacing_PARALLEL} ;
    PROPERTY LEF57_SPACING "SPACING {wire_spacing_PARALLEL} PARALLELOVERLAP ;" ;
END VIA{i}
"""


def get_layer_lef(i):
    return f"""
LAYER M{i}
    TYPE ROUTING ;
    DIRECTION {"HORIZONTAL" if i % 2 == 1 else "VERTICAL"} ;
    PITCH {pitch} ;
    WIDTH {wire_width} ;
    THICKNESS {wire_width} ;
    SPACING {wire_spacing_PARALLEL} ;
    SPACING {wire_spacing_SAMENET} SAMENET ;
    AREA {wire_width*placement_grid_size} ; # 1xmin_space wire is minarea (signifying a dot - needed for vias)

    # PROPERTY LEF57_SPACING "SPACING {wire_spacing_EOL} ENDOFLINE {wire_width} WITHIN {wire_spacing_PARALLEL} ; " ;


    RESISTANCE RPERSQ 0.001 ;
    CAPACITANCE CPERSQDIST 0.0001 ;
    EDGECAPACITANCE 0.0001 ;
    MINIMUMDENSITY 0
    MAXIMUMDENSITY 100
END M{i}
"""


def get_via_def_between(i, j):
    assert(i + 1 == j)
    via_length = placement_grid_size
    return f"""
VIA VIA{i}{j}H DEFAULT
    LAYER M{j} ;
        RECT -{wire_width/2} -{wire_width/2} {wire_width/2} {wire_width/2} ;
    LAYER VIA{i} ;
        RECT -{wire_width/2} -{wire_width/2} {wire_width/2} {wire_width/2} ;
    LAYER M{i} ;
        RECT -{wire_width/2} -{wire_width/2} {wire_width/2} {wire_width/2} ;
END VIA{i}{j}H

VIA VIA{i}{j}V DEFAULT
    LAYER M{j} ;
        RECT -{wire_width/2} -{wire_width/2} {wire_width/2} {wire_width/2} ;
    LAYER VIA{i} ;
        RECT -{wire_width/2} -{wire_width/2} {wire_width/2} {wire_width/2} ;
    LAYER M{i} ;
        RECT -{wire_width/2} -{wire_width/2} {wire_width/2} {wire_width/2} ;
END VIA{i}{j}V
"""

def export_lef(n_layers, ofile):
    to_write = f"""VERSION 5.7 ;
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

    to_write += """
LAYER OVERLAP
    TYPE OVERLAP ;
END OVERLAP
"""
    for i in range(1, n_layers):
        to_write += get_via_def_between(i, i+1)
    # for i in range(1, n_layers):
    #     to_write += get_viarule_between(i, i+1)
    # Consult pg. 180 in LEF doc
    # I don't think site symmetry is useful in this case because we only have one site type
    to_write += f"""
SITE mc_site
    SIZE {placement_grid_size} BY {standard_cell_height + 2 * placement_grid_size} ;
    CLASS CORE ;
    # SYMMETRY X Y ;
END mc_site
"""
    for cell in c.cells:
        to_write += cell.layout.cell2lefabstract(cell.name, cell.ipins)
    to_write += "END LIBRARY\n"
    with open(ofile, 'w') as f:
        f.write(to_write)

