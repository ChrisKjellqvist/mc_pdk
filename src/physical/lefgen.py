

"""
Having people install KLayout just to generate LEF files is a bit much. This module will generate LEF files
from a set of strings. The strings will be formatted as follows:
g = grass
b = "buffer" (a redstone repeater)
x|- = wires (cross, vertical, horizontal)
t = torch

whitespace ignored
For each component with a relevant directionality, you can specify udlr for "up", "down", "left", "right" as a prefix
for torches and buffers.

Each component will only be a single layer!!!
Having people install KLayout just to generate LEF files is a bit much. This module will generate LEF files
from a set of strings. The strings will be formatted as follows:
g = grass
b = "buffer" (a redstone repeater)
r = redstone wires
t = torch
s = target block
e = empty
p = piston

whitespace ignored
For each component with a relevant directionality, you can specify udlr for "up", "down", "left", "right", "middle" as a prefix
for torches(side of block, middle is valid), buffers (direction, middle invalid), pistons (direction, middle invalid).

Each component will only be a single layer!!!
Inputs and outputs should be given using the capital latter corresponding to it as a prefix prefix
Clock signal given symbol '~'
Buffers can be given a number as a suffix to specify the delay 1-4 (1 is default) after the buffer
(ex. ub2) is a up facing buffer with delay 2ticks
--------------------------------------------------
Prefix example:

dt
g

is a grass with a torch blow on the top side
--------------------------------------------------
Layout example 2NAND:

 dt  Y-  dt
 s   e   s
 Ar  e   Ar
--------------------------------------------------
NMUX2 example:
e   Or  e  lb1 lb1 Ar
e   r   s  lb1  r  e
Sr  rb1 up  e   Br  e
--------------------------------------------------
DFF example:

dt  rb1  ub1
s   rb1  ub1
~r   e   Dr

--------------------------------------------------
For the purposes of the LEF file, we'll draw a rectangle
on M1 for everything that's not a pin using SPNET rules
and a rectangle on M1 for redstone wires using NET rules
"""

if __name__ == "__main__":
    ofile = "test.lef"
    n_layers = 9
    with open(ofile, "w") as f:
        f.write("""VERSION 5.6 ;
BUSBITCHARS "[]" ;
DIVIDERCHAR "/" ;

UNITS
    DATABASE MICRONS 1
END UNITS

MANUFACTURINGGRID 100 ;
PROPERTYDEFINITIONS
    LAYER LEF57_SPACING STRING ;
    LAYER LEF57_MINSTEP STRING ;
END PROPERTYDEFINITIONS
""")
        def write_layer(q, i, do_via):
            q.write(f"""
LAYER M{i}
    TYPE ROUTING
    DIRECTION {"HORIZONTAL" if i % 2 == 0 else "VERTICAL"} ;
    PITCH 1 ;
    WIDTH 1 ;
    SPACING 100 ;
    AREA 200 ; # 1x100 wire is minarea
    
    PROPERTY LEF57_SPACING "SPACING 100 ENDOFLINE 1 WITHIN 1 PARALLELEDGE 1 WITHIN 1 ;" ;
    
END M{i}
""" + f"""
LAYER VIA{i}
    TYPE CUT ;
    SPACING 100 ;
    PROPERTY LEF57_SPACING "SPACING 100 PARALLELOVERLAP ;" ;
END VIA{i}

VIA VIA{i}{i+1} Default
    LAYER M{i+1} ;
        RECT -1 -1 1 1 ;
    LAYER VIA{i} ;
        RECT -1 -1 1 1 ;
    LAYER M{i} ;
        RECT -1 1 1 1 ;
END VIA{i}{i+1}

VIARULE VIAGEN{i} GENERATE
    LAYER{i+1} ;
        ENCLOSURE 1 1 ;
        WIDTH 1 TO 1 ;
    LAYER VIA{i} ;
        ENCLOSURE 1 1 ;
        WIDTH 1 TO 1 ;
    LAYER{i} ;
        ENCLOSURE 1 1 ;
        WIDTH 1 TO 1 ;
END VIDAGEN{i}

SITE core10T
    SIZE 10000 BY 10000 ;
    CLASS CORE ;
    SYMMETRY Y ;
END core10T


        
""" if do_via else "")

        for i in range(1, n_layers + 1):
            write_layer(f, i, i < n_layers)

