from mc_pdk.libgen import cell as c
from mc_pdk.libgen.layout import Layout


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
        delay=2,
        area=12,
        postamble="""
                       next_state: "D";
                       clocked_on: "CLK";""",
        postamble_name="IQ",
        other_ipins=[],
        layout=Layout(1, ["e   e   Qw\n"
                          "dt  rb1  ub1\n"
                          "s   rb1  ub1\n"
                          "~w   e   Dw"]))
    # generate_dff_with_settings(
    #     name="DFFNEG",
    #     delay=1,
    #     area=12,
    #     postamble="""
    #                        next_state: "D";
    #                        clocked_on: "!CLK";""",
    #     postamble_name="IQ",
    #     other_ipins=[],
    #     layout=Layout(1, ["~w  e   Qw\n"
    #                       "s   rb1  ub1\n"
    #                       "ut  rb1  ub1\n"
    #                       "e   e   Dw"]))
    generate_dff_with_settings(
        name="DFFE",  # DFF with enable (active high)
        area=20,
        delay=2,
        postamble_name="IQ",
        postamble=f"""
            next_state: "((E * D) + (!E IQ))";
            clocked_on: "CLK";
""",
        other_ipins=[("E", True)],
        layout=Layout(accessible_layers=1,
                      l=["e e Qw e e\n"
                         "e e e e e\n"
                         "w e e e w\n"
                         "~w e Dw e Ew",

                         "e e g e e\n"
                         "dt rb1 ub1 lb1 dt\n"
                         "g rb1 ub1 g g\n"
                         "g e g e g"]))
    generate_dff_with_settings(
        name="DFFERH",  # DFF with enable, synchronous reset high
        area=28,
        delay=2,
        postamble_name="IQ",
        postamble=f"""
            next_state: "((E * D) + (!E IQ) + R)";
            clocked_on: "CLK";
""",
        other_ipins=[("E", True), ("R", True)],
        layout=Layout(
            accessible_layers=1,
            l=["e e Qw lb1 lb1 w w\n"
               "e e e e dt e w\n"
               "w e e e s w w\n"
               "~w e Dw e Ew e Rw",

               "e e g g g g g\n"
               "e rb1 ub1 lb1 w e g\n"
               "g rb1 ub1 g g g g\n"
               "g g g g g e g"]))
    generate_dff_with_settings(
        name="DFFERL",  # DFF with enable, synchronous reset high
        area=32,
        delay=4,
        postamble_name="IQ",
        postamble=f"""
                next_state: "((E * D) + (!E IQ)) * !R";
                clocked_on: "CLK";
    """,
        other_ipins=[("E", True), ("R", True)],
        layout=Layout(accessible_layers=1,
                      l=["e e e w s lt mt Qw\n"
                         "e e e e dt e e e\n"
                         "w e e e s w w e\n"
                         "~w e Dw e Ew e Rw",

                         "e e w g g w s g\n"
                         "dt rb1 ub1 lb1 w e w g\n"
                         "g rb1 ub1 g g g g g\n"
                         "g g g g g g g g"
                          ]))
