from src.liberty import cell as c
from src.liberty.cell import Layout


def declare_sequential_cells():
    c.Cell("DFF", c.SEQUENTIAL, delay=1, area=12,
           ipins=[c.InputPin("D",
                             additional_timing_arcs=f"""
nextstate_type : data;
timing() {{
    related_pin: "CLK";
    timing_type: hold_rising;
    rise_constraint(hold_template) {{
{c.hold_input}
    }}
    fall_constraint(hold_template) {{
{c.hold_input}
    }}
}}
        
timing() {{
    related_pin: "CLK";
    timing_type: setup_rising;
    rising_constraint(setup_template) {{
{c.setup_input.format(delay=1)}
    }}
    fall_constraint(setup_template) {{
{c.setup_input.format(delay=1)}
    }}
}}
"""),
                  c.InputPin("CLK", is_clock=True,
                             additional_timing_arcs="""
timing() {
    related_pin : "CLK";
    timing_type : min_pulse_width;
    rise_constraint(width_template) {
    index_1 ("0, 10000");
    values ("0, 0");
    }
    fall_constraint(width_template) {
    index_1 ("0, 10000");
    values ("0, 0");
    }
}

""")],
           opins=[c.OutputPin("Q", "IQ", timing_sense="rising_edge")],
           optional_postamble="""        ff (IQ, IQN) {
                   next_state: "D";
                   clocked_on: "CLK";
              }""", is_sequential=True,
           layout=Layout(["e   e   Qw\n"
                          "dt  rb1  ub1\n"
                          "s   rb1  ub1\n"
                          "~w   e   Dw"]))
