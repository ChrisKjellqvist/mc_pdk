from enum import Enum
import src.liberty.cell as c
from src.global_constants import grid_size

"""
Having people install KLayout just to generate LEF files is a bit much. This module will generate LEF files
from a set of strings. The strings will be formatted as follows:
g = grass
b = "buffer" (a redstone repeater)
w = wires (cross, vertical, horizontal)
t = torch

whitespace ignored
For each component with a relevant directionality, you can specify udlr for "up", "down", "left", "right" as a prefix
for torches and buffers.

Each component will only be a single layer!!!
Having people install KLayout just to generate LEF files is a bit much. This module will generate LEF files
from a set of strings. The strings will be formatted as follows:
g = grass
b = "buffer" (a redstone repeater)
w = redstone wires
t = torch
s = target block
e = empty
p = piston

whitespace ignored
For each component with a relevant directionality, you can specify udlr for "up", "down", "left", "right", "middle" 
as a prefix for torches(side of block, middle is valid), buffers (direction, middle invalid), 
pistons (direction, middle invalid).

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

 dt  Yw  dt
 s   e   s
 Aw  e   Aw
--------------------------------------------------
NMUX2 example:
e   Ow  e  lb1 lb1 Aw
e   w   s  lb1  w  e
Sw  rb1 up  e   Bw  e
--------------------------------------------------
DFF example:
e   Qw    w
dt  rb1  ub1
s   rb1  ub1
~w   e   Dw

--------------------------------------------------
For the purposes of the LEF file, we'll draw a rectangle
on M1 for everything that's not a pin using SPNET rules
and a rectangle on M1 for redstone wires using NET rules

Grammar:
layout = 
    | line*
line = 
    | (block whitespace)+
block = 
    | [udlrm] directionable
    | [A-Z~] w
    | [gse]
directionable =
    | [tp]
    | [b] [1-4]?
"""


class Block(Enum):
    GRASS = "g"
    BUFFER = "b"
    REDSTONE = "w"
    TORCH = "t"
    TARGET = "s"
    EMPTY = "e"
    PISTON = "p"


class Direction(Enum):
    UP = "u"
    DOWN = "d"
    LEFT = "l"
    RIGHT = "r"
    MIDDLE = "m"
    UNDEF = '-'

class Entity:
    def __init__(self, block: Block):
        self.block = block
        self.direction = Direction.UNDEF
        self.x = -1
        self.y = -1
        self.buffer = -1
        self.pin_name = None


def directionable(tok: str) -> (Entity, str):
    ft = tok[0]
    if ft in "tp":
        return Entity(Block(ft)), tok[1:]
    elif ft == "b":
        if len(tok) == 1:
            return Entity(Block.BUFFER), tok[1:]
        else:
            if tok[1] in "1234":
                e = Entity(Block.BUFFER)
                e.buffer = int(tok[1])
                return e
            else:
                return Entity(Block.BUFFER), tok[2:]
    else:
        raise ValueError(f"Invalid directionable token: '{ft}'")


def block(tok: str) -> (Entity, str):
    ft = tok[0]
    if tok[0] in "udlrm":
        blk, next_tok = directionable(tok[1:])
        blk.direction = Direction(ft)
        return blk, next_tok
    elif tok[0] in "A-Z~":
        e = Entity(Block.REDSTONE), tok[1:]
        e.pin_name = tok[0]
        return e
    elif tok[0] in "gse":
        return Entity(Block(tok[0])), tok[1:]
    else:
        raise ValueError(f"Invalid block token: '{ft}'")


def line(ln: str) -> [Entity]:
    blocks = []
    while len(ln) > 0:
        blk, ln = block(ln)
        blocks.append(blk)
        # whitespace
        ln = ln.strip()
    return blocks


def layout(input_str: str) -> [[Entity]]:
    lns = input_str.split("\n")
    acc = []
    for ln in lns:
        if len(ln) == 0:
            continue
        else:
            acc.append(line(ln))
    # first line should be the top (highest index)
    acc.reverse()
    return acc

def cell2lefAbstract(cell: c.Cell):
    """
    Abstract LEF DO NOT contain _all_ the information you need to get a GDS typically. Just the stuff that you
    need to do PnR. So what will we do? We'll have the wires that are used for pins and then, because there's
    plenty of stuff in MC that breaks typical silicon routing rules (e.g., torches, repeaters having different
    routing from redstone routing), we add filler that's not real obviously, but will provide the PnR tool with
    enough information so that they don't generate invalid routes when we introduce torches and repeaters and such.

    I don't imagine that we'll generate an actual GDS. Probably just take the layout (which I believe contains routes)
    as well as the cell placements and infer the rest.
    """
    lout = layout(cell.layout_str)
    preamble = f"""
MACRO {cell.name} {{
    CLASS CORE ;
    ORIGIN 0 0 ;
    FOREIGN {cell.name} ;
    SIZE {len(lout[0]) * grid_size} BY {len(lout)} ;
    SYMMETRY X Y ;
    SITE mc_site ;
"""
    # start walking through layout. IF WE SEE PIN, then we draw it
    # connecting through AT LEAST 1 element of its source s.t., we
    # satisfy min-length requirements but don't run into the input pin

    blockages = set()
    visited = set()
    pin_wires = list()
    rows = len(lout)
    cols = len(lout[0])
    for i in range(rows):
        row = lout[i]
        for j in range(cols):
            ele = row[j]
            if (i, j) in visited:
                continue
            visited.add((i, j))
            if ele.pin_name is None:
                blockages.add((i, j))
            # find any connected wires and add them as a group
            pin_wires.append((ele.pin_name, (i, j)))
    """ Turn these blockages and wires into a LEF! Take DFF for instance
        e   e    Qw
        dt  rb1  ub1
        s   rb1  ub1
        ~w   e   Dw
        Needs to turn into (x = blockage on M1)
        X X _ <- Q
        X X X
        X X X
   clk->| X |<- D
"""
    for i, (x, y) in pin_wires:
        direction = "OUTPUT"
        for iwr in cell.ipins:
            if iwr.name == i:
                direction  = "INPUT"
                break
        preamble += f"""
    PIN {i}
        DIRECTION {direction} ;
        PORT 
        LAYER M1 ;
        RECT {x * grid_size - 0.5} {y * grid_size - 0.5} {x * grid_size + 0.5} {x * grid_size + 0.5}
    END {i}
"""
    preamble += f"""
    OBS
# obstructions
    """





