from src.liberty import cell as c
from src.liberty.cell import Layout


def declare_sequential_cells():
    c.Cell("DFF", c.SEQUENTIAL, delay=1, area=12,
           ipins=[c.InputPin("D"), c.InputPin("CLK")],
           opins=[c.OutputPin("Q", "IQ", timing_sense="rising_edge")],
           optional_postamble="""        ff (IQ, IQN) {
                   next_state: "D";
                   clocked_on: "CLK";
              }""", is_sequential=True,
           layout=Layout(["e   e   Qw\n"
                          "dt  rb1  ub1\n"
                          "s   rb1  ub1\n"
                          "~w   e   Dw"]))
