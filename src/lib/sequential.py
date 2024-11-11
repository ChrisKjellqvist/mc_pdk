import cell as c

# only the last repeater needs to change to trigger an output switch,
# and we'll allow routing on M1 so we don't include the delay of the
# up via
c.Cell("DFF", c.SEQUENTIAL, 1, 12,
       [c.InputPin("D"), c.InputPin("CLK")],
       [c.OutputPin("Q", "IQ", timing_sense="rising_edge")],
       optional_postamble="""        ff (IQ, IQN) {
            next_state: "D";
            clocked_on: "CLK";
       }""", is_sequential=True)


# }""", additional_timings={"C":
#                                    f"""             timing() {{
#       related_pin : "Q";
#       timing_sense : non_unate;
#       cell_rise(delay_template) {{
#             index_1 ("1");
#             values (1);
#       }}
# }}"""})

