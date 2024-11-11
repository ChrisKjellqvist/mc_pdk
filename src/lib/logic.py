import cell as c
import grammar as gr
from src.lib.cell import InputPin, OutputPin

# OR gate
def gen_or(n_inputs):
    assert 7 >= n_inputs >= 2
    c.Cell("OR%d" % n_inputs,
           c.COMBINATIONAL,
           0,
           3 + 6 * (n_inputs-1),
           [InputPin(gr.alphabet_input[i]) for i in range(n_inputs)],
           [OutputPin("Y", "+".join(gr.alphabet_input[:n_inputs]))])

# ANDD gate - AND "dense"
# it's possible to have parallel wires with alternating repeaters but this adds
# at least +1 delay and the associated area so it's probably only worth it for
# very large gates
# def gen_andd(n_inputs):
#     assert 7 >= n_inputs >= 2
#     c.Cell("AND%d" % n_inputs, c.COMBINATIONAL, 2, 2 * n_inputs - 1)

def gen_and(n_inputs):
    """
    AND for n_inputs > 2
    :param n_inputs:
    :return:
    """
    assert 7 >= n_inputs >= 3
    c.Cell("AND%d" % n_inputs,
           c.COMBINATIONAL,
           2,
           6 * (n_inputs + 2),
           [InputPin(gr.alphabet_input[i]) for i in range(n_inputs)],
              [OutputPin("Y", "*".join(gr.alphabet_input[:n_inputs]))])


# ANDS gate - AND "sparse"
# yikes
c.Cell("AND2", c.COMBINATIONAL, 2, 18, [InputPin("A"), InputPin("B")], [OutputPin("Y", "A*B")])

# # INV
c.Cell("INV", c.COMBINATIONAL, 1, 9, [InputPin("A")], [OutputPin("Y", "!A")])

# NAND
c.Cell("NAND2", c.COMBINATIONAL, 2, 12, [InputPin("A"), InputPin("B")], [OutputPin("Y", "!(A*B)")])

# OR2,3,4,5
for i in range(4):
    gen_or(i + 2)

c.Cell("MUX2", c.COMBINATIONAL, 4, 18, [InputPin("A"), InputPin("B"), InputPin("S")], [OutputPin("Y", "A*S + B*!S")])

c.Cell("BUF", c.COMBINATIONAL, 0, 9, [InputPin("A")], [OutputPin("Y", "A")])