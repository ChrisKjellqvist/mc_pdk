from enum import Enum

import src.liberty.cell as c
from src.global_constants import *
from src.liberty.grammar import *

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
    | [A-Z~] [uldrm] t
    | [gsew]
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
                return e, tok[2:]
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
    elif tok[0] in (alphabet_input + alphabet_output + "~"):
        if tok[1] == 'w':
            e = Entity(Block.REDSTONE)
            ntok = tok[2:]
        else:
            assert tok[1] in "uldrm"
            e = Entity(Block.TORCH)
            e.direction = Direction(tok[1])
            ntok = tok[3:]
        e.pin_name = tok[0]
        return e, ntok
    elif tok[0] in "gsew":
        return Entity(Block(tok[0])), tok[1:]
    else:
        raise ValueError(f"Invalid block token: '{ft}'")


def line(ln: str) -> [Entity]:
    ln = ln.strip()
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


class Layout:
    """
    Provide the layout according to the grammar in lefgen_abstract
    Each element of `l` is a separate layer with M1 (top user-accessible layer)
    as the index [0] and other layers going consecutively downwards
    """
    def __init__(self, accessible_layers: int, l: list[str]):
        self.lout = l
        self.accessible_layers = accessible_layers

    def cell2lefabstract(self, name, ipins):
        """
        Abstract LEF DO NOT contain _all_ the information you need to get a GDS typically. Just the stuff that you
        need to do PnR. So what will we do? We'll have the wires that are used for pins and then, because there's
        plenty of stuff in MC that breaks typical silicon routing rules (e.g., torches, repeaters having different
        routing from redstone routing), we add filler that's not real obviously, but will provide the PnR tool with
        enough information so that they don't generate invalid routes when we introduce torches and repeaters and such.

        I don't imagine that we'll generate an actual GDS. Probably just take the layout (which I believe contains routes)
        as well as the cell placements and infer the rest.
        """
        # start walking through layout. IF WE SEE PIN, then we draw it
        # connecting through AT LEAST 1 element of its source s.t., we
        # satisfy min-length requirements but don't run into the input pin
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
            Although, because of minspacing requirements We'll need to give the
            pins space so that we can route to clk, D, and Q so it will need to
            look like... (E for empty)
            X E _
            X X E
            E X E
            | E |

            Although the Es are empty, we won't be able to route anything there
            due to the X obstructions and minspacing requirements
    """

        for lidx in range(self.accessible_layers):
            layer_name = f"M{lidx+1}"
            ar_idx = self.accessible_layers-1-lidx
            blockages = set()
            visited = set()
            pin_wires = list()
            lout = layout(self.lout[ar_idx])
            rows = len(lout)
            cols = len(lout[0])
            if lidx == 0:
                cell_lef = f"""
                MACRO {name}
                    CLASS CORE ;
                    ORIGIN 0 0 ;
                    FOREIGN {name} ;
                    SIZE {len(lout[0]) * grid_size} BY {len(lout) * grid_size} ;
                    SYMMETRY X Y ;
                    SITE mc_site ;
                """
            for i in range(rows):
                row = lout[i]
                for j in range(cols):
                    ele = row[j]
                    if (i, j) in visited:
                        continue
                    visited.add((i, j))
                    if ele.pin_name is None:
                        blockages.add((i, j))
                        continue
                    # find any connected wires and add them as a group
                    pin_wires.append((ele.pin_name, (i, j)))
            for i, (w_r, w_c) in pin_wires:
                direction = "OUTPUT"
                if i == '~':
                    nm = "CLK"
                else:
                    nm = i
                for iwr in ipins:
                    if iwr.name == i:
                        direction = "INPUT"
                        break
                cell_lef += f"""
            PIN {nm}
                DIRECTION {direction} ;
                PORT 
                LAYER {layer_name} ;
                RECT {w_c * grid_size + grid_offset} {w_r * grid_size + grid_offset} {w_c * grid_size + 1 + grid_offset} {w_r* grid_size + 1 + grid_offset} ;
                END
            END {nm}
        """
            cell_lef += f"\n\tOBS\n\t\tLAYER {layer_name} ;\n"

            invalid_blockage_locations = set()
            for _, (i ,j) in pin_wires:
                for di, dj in [(-1, 0), (1, 0), (0, -1), (0, 1), (0, 0)]:
                    invalid_blockage_locations.add((i+di, j+dj))

            for c in range(cols):
                # find base row to start a blockage
                base = -1
                for r in range(rows):
                    if (r, c) in invalid_blockage_locations:
                        if base != -1:
                            cell_lef += f"RECT {c * grid_size + grid_offset} {base * grid_size + grid_offset} {c * grid_size + grid_offset + 1} {(r-1)*grid_size+grid_offset+1} ;\n"
                            base = -1
                        continue
                    if base == -1:
                        base = r
                        continue
                if base != -1:
                    cell_lef += f"RECT {c * grid_size + grid_offset} {base * grid_size + grid_offset} {c * grid_size + grid_offset + 1} {(rows-1) * grid_size + grid_offset + 1} ;\n"
            cell_lef += "\tEND\n"
        cell_lef += f"END {name}\n"
        return cell_lef
