from src.liberty import cell as c
from src.liberty.cell import Layout


def declare_sequential_cells():
    def generate_dff_with_settings(name: str,
                                   delay: int,
                                   area: int,
                                   other_ipins: list[(str, bool)],
                                   postamble,
                                   postamble_name,
                                   layout):
        ipins = [c.InputPin("D",
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
        rise_constraint(setup_template) {{
    {c.setup_input.format(delay=delay)}
        }}
        fall_constraint(setup_template) {{
    {c.setup_input.format(delay=delay)}
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
    
    """)]
        for pin_name, is_sync in other_ipins:
            if is_sync:
                ipins += [
                    c.InputPin(pin_name, is_clock=False,
                               additional_timing_arcs=f"""
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
                            rise_constraint(setup_template) {{
                        {c.setup_input.format(delay=delay)}
                            }}
                            fall_constraint(setup_template) {{
                        {c.setup_input.format(delay=delay)}
                            }}
                        }}""")]
            else:
                ipins += [
                    c.InputPin(pin_name)
                ]
        c.Cell(name, c.SEQUENTIAL, delay=delay, area=area,
               ipins=ipins,
               opins=[c.OutputPin("Q", postamble_name, timing_sense="rising_edge")],
               optional_postamble=f"""
        ff ({postamble_name}, {postamble_name}N) {{
{postamble}
        }}""", is_sequential=True,
               layout=layout)

    generate_dff_with_settings(
        name="DFF",
        delay=1,
        area=12,
        postamble="""
                       next_state: "D";
                       clocked_on: "CLK";""",
        postamble_name="IQ",
        other_ipins=[],
        layout=Layout(["e   e   Qw\n"
                       "dt  rb1  ub1\n"
                       "s   rb1  ub1\n"
                       "~w   e   Dw"]))
    generate_dff_with_settings(
        name="DFFNEG",
        delay=1,
        area=12,
        postamble="""
                           next_state: "D";
                           clocked_on: "!CLK";""",
        postamble_name="IQ",
        other_ipins=[],
        layout=Layout(["~w  e   Qw\n"
                       "s   rb1  ub1\n"
                       "ut  rb1  ub1\n"
                       "e   e   Dw"]))
    generate_dff_with_settings(
        name="DFFE", # DFF with enable (active high)
        area=25,
        delay=1,
        postamble_name="IQ",
        postamble=f"""
            next_state: "((E * D) + (!E IQ))";
            clocked_on: "CLK";
""",
        other_ipins=[("E", True)],
        layout=Layout(["e   e   e   e   Qw\n"
                       "e   dt  w   rb1 ub1\n"
                       "Ew  s   dt  e   w\n"
                       "e   e   s   rb1 ub1\n"
                       "e   e   ~w  e   Dw"]))
    generate_dff_with_settings(
        name="DFFERH", # DFF with enable, synchronous reset high
        area=25,
        delay=3,
        postamble_name="IQ",
        postamble=f"""
            next_state: "((E * D) + (!E IQ) + R)";
            clocked_on: "CLK";
""",
        other_ipins=[("E", True), ("R", True)],
        layout=Layout(["e   e   e   e   Qw\n"
                       "e   dt  w   rb1 ub1\n"
                       "Ew  s   dt  e   Rw\n"
                       "w   e   s   rb1 ub1\n"
                       "e   e   ~w  e   Dw",

                       "g   g   g   g   g\n"
                       "g   g   g   g   g\n"
                       "g   w   lb1 w   g\n"
                       "g   w   g   g   g\n"
                       "g   g   g   g   g"
                       ]))
    generate_dff_with_settings(
        name="DFFERL",  # DFF with enable, synchronous reset high
        area=30,
        delay=3,
        postamble_name="IQ",
        postamble=f"""
                next_state: "((E * D) + (!E IQ)) * !R";
                clocked_on: "CLK";
    """,
        other_ipins=[("E", True), ("R", True)],
        layout=Layout(["e   g   lb1 w   dt  e\n"
                       "Dw  dt  ub1 e   s   Dw\n"
                       "e   ut  w   e   e   e\n"
                       "e   s   lt  s   w   Rw\n"
                       "e   ~w  e   Ew  e   e",

                       "g   g   g   g   w   g\n"
                       "g   g   g   g   ub1 g\n"
                       "g   g   g   g   w   g\n"
                       "g   g   g   g   g   g\n"
                       "g   g   g   g   g   g"
                       ]))

