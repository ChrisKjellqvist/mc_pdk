import cell as c
import grammar as gr
from src.lib.cell import InputPin, OutputPin

# OR gate
def gen_orn(n_inputs):
    assert 7 >= n_inputs >= 2
    c.Cell("OR%d" % n_inputs,
           c.COMBINATIONAL,
           0,
           4 * (2 * n_inputs-1),
           [InputPin(gr.alphabet_input[i]) for i in range(n_inputs)],
           [OutputPin("Y", "+".join(gr.alphabet_input[:n_inputs]))])
    for i in range(1, n_inputs):
        f = list(gr.alphabet_input[:n_inputs])
        for j in range(i):
            f[j] = "!" + f[j]
        c.Cell(f"OR{n_inputs}_{i}",
               c.COMBINATIONAL,
               1,
               4 * (2 * n_inputs-1),
               [InputPin(gr.alphabet_input[i]) for i in range(n_inputs)],
               [OutputPin("Y", "+".join(f))])


# ANDD gate - AND "dense"
# it's possible to have parallel wires with alternating repeaters but this adds
# at least +1 delay and the associated area so it's probably only worth it for
# very large gates
# def gen_andd(n_inputs):
#     assert 7 >= n_inputs >= 2
#     c.Cell("AND%d" % n_inputs, c.COMBINATIONAL, 2, 2 * n_inputs - 1)

def gen_norn(n_inputs):
    """
    NOR with inverted inputs (all inputs inverted equivalent to AND)
    :param n_inputs:
    :return:
    """
    assert 7 >= n_inputs >= 2
    for i in range(n_inputs):
        f = list(gr.alphabet_input[:n_inputs])
        for j in range(i):
            f[j] = "!" + f[j]
        c.Cell(f"NOR{n_inputs}_{i}",
               c.COMBINATIONAL,
               2,
               6 * (2 * n_inputs - 1),
               [InputPin(gr.alphabet_input[i]) for i in range(n_inputs)],
                  [OutputPin("Y", "*".join(f))])


# ANDS gate - AND "sparse"
# yikes
# c.Cell("AND2", c.COMBINATIONAL, 2, 18, [InputPin("A"), InputPin("B")], [OutputPin("Y", "A*B")])

# # INV
c.Cell("INV", c.COMBINATIONAL, 1, 9, [InputPin("A")], [OutputPin("Y", "!A")])

# NAND
c.Cell("NAND2", c.COMBINATIONAL, 2, 12, [InputPin("A"), InputPin("B")], [OutputPin("Y", "!(A*B)")])

# OR2,3,4,5
for i in range(5):
    gen_orn(i + 2)
    gen_norn(i + 2)


c.Cell("NMUX2", c.COMBINATIONAL, 4, 18, [InputPin("A"), InputPin("B"), InputPin("S")], [OutputPin("Y", "!A*S + !B*!S")])

c.Cell("BUF", c.COMBINATIONAL, 0, 9, [InputPin("A")], [OutputPin("Y", "A")])