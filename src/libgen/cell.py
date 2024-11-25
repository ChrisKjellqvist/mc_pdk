import src.libgen.grammar as gr
from src.libgen.layout import Layout

COMBINATIONAL = 0
SEQUENTIAL = 1
PHYSICAL = 2
global cells
global fstr

delay_template = """variable_1 : input_net_transition;
variable_2 : total_output_net_capacitance;
index_1 ("0, 10000");
index_2 ("0, 10000");
"""

delay_input = """index_1 ("0, 10000");
index_2 ("0, 10000");
values ("{delay}, {delay}","{delay}, {delay}");
"""

hold_template = """
variable_1 : related_pin_transition;
variable_2 : constrained_pin_transition;
index_1 ("0, 10000");
index_2 ("0, 10000");
"""

setup_template = """
    variable_1 : related_pin_transition;
    variable_2 : constrained_pin_transition;
    index_1 ("0, 10000");
    index_2 ("0, 10000");
"""

setup_input = """
index_1 ("0, 10000");
index_2 ("0, 10000");
values ("{delay}, {delay}","{delay}, {delay}");
"""


hold_input = """
index_1 ("0, 10000");
index_2 ("0, 10000");
values ("0, 0", "0, 0");"""

width_template = """
variable_1 : related_pin_transition;
index_1 ("0, 10000");
  """


class InputPin:
    def __init__(self, name, is_clock=False, additional_timing_arcs=None):
        self.name = name
        self.is_clock = is_clock
        self.additional_timing_arcs=additional_timing_arcs

    def to_str(self, opts=None):
        timing = ""
        if opts is not None:
            if self.name in opts:
                timing = opts[self.name]

        return f"""        pin({self.name}) {{
            input_signal_level: VDD;
            related_ground_pin: VSS;
            related_power_pin: VDD;
            direction : input;
            capacitance : 0;
            clock : {'true' if self.is_clock else 'false'};
            {timing}
{self.additional_timing_arcs if self.additional_timing_arcs is not None else ""}
        }}"""


class OutputPin:
    def __init__(self,
                 name,
                 f,
                 timing_sense="positive_unate",):
        self.name = name
        self.f = f
        self.timing_sense = timing_sense

    def to_str(self, related_pins, delay, is_sequential):
        timings = []
        newline = "\n"

        if is_sequential:
            tt1 = f"timing_type: {self.timing_sense};"
            tt2 = ""
            pins_to_condition = list(filter(lambda x: x.name == "CLK", related_pins))
        else:
            tt1 = "timing_type: combinational;"
            tt2 = ""#f"timing_sense: {self.timing_sense};"
            pins_to_condition = related_pins
        for pin in pins_to_condition:
            timings.append(f"""
timing() {{
    related_pin : "{pin.name}";
    {tt1}
    {tt2}
    cell_rise(delay_template) {{
{delay_input.format(delay=delay)}
    }}
    cell_fall(delay_template) {{
{delay_input.format(delay=delay)}
    }}
    rise_transition(delay_template) {{
{delay_input.format(delay=delay)}
    }}
    fall_transition(delay_template) {{
{delay_input.format(delay=delay)}
    }}
}}
""")
        return f"""        pin({self.name}) {{
            direction : output;
            function : "{self.f}";
{newline.join(timings)}
        }}"""


class Cell:
    def __init__(self,
                 name,
                 cell_type,
                 delay,
                 area,
                 ipins: list[InputPin],
                 opins: list[OutputPin],
                 layout: Layout,
                 optional_preamble="",
                 optional_postamble="",
                 additional_timings=None,
                 is_sequential=False,
                 ):
        self.name = name
        self.cell_type = cell_type
        # delay input is TICK! convert to ms
        self.delay = delay
        self.area = area
        self.optional_preamble = optional_preamble
        self.optional_postamble = optional_postamble
        self.is_sequential = is_sequential
        self.layout = layout
        self.ipins = ipins
        self.opins = opins
        assert self.delay >= 0
        for opin in opins:
            gr.check_function(opin.f)
        # the minimum area should be 9 because you need padding to route
        # on either side of the compute
        # So...
        # O^O
        # OB0
        # O^0
        global cells
        for c in cells:
            if c.name == name:
                raise Exception("Cell with name %s already exists" % name)
        cells.append(self)
        self.pins_str = "\n".join([pin.to_str(additional_timings) for pin in ipins] +
                                  [pin.to_str(ipins, delay, self.is_sequential) for pin in opins])

    def to_str(self):
        s = f"""    cell({self.name}) {{
        area : {self.area};
        pg_pin (VDD) {{
            direction : input;
            voltage_name : "VDD";
            pg_type : primary_power;
        }}
        pg_pin (VSS) {{
            direction : input;
            voltage_name : "VSS";
            pg_type : primary_ground;
        }}
{self.optional_preamble}
{self.pins_str}
{self.optional_postamble}
    }}"""
        return s


def init_cells():
    global cells
    cells = []


def export_lib(ofile):
    print("Exporting library")
    cell_str = "\n".join([c.to_str() for c in cells])
    with open(ofile, "w") as f:
        f.write(f"""library (mc_cells) {{
    revision : "1.0";
    technology : "cmos";
    delay_model: table_lookup;
    voltage_unit : "1V";
    time_unit : "1ns";
    pulling_resistance_unit : "1kohm";
    leakage_power_unit : "1nW";
    capacitive_load_unit (1,ff);

    voltage_map (VDD, 1);
    voltage_map (VSS, 0);
    default_fanout_load: 0;
    default_input_pin_cap: 0;
    default_output_pin_cap: 0;
    default_inout_pin_cap: 0;
    default_cell_leakage_power : 0;
    default_connection_class : "signal";
    current_unit : "1uA";
    
    nom_voltage: 1;
    nom_process: 1;
    nom_temperature: 100;
    
    operating_conditions (sunny_day) {{
        process : 1;
        temperature : 100;
        voltage : 1;
    }}    
    default_operating_conditions : sunny_day;
    lu_table_template (delay_template) {{
{delay_template}  
    }};
    lu_table_template (hold_template) {{
{hold_template}
    }};
    lu_table_template (setup_template) {{
{setup_template}
    }};
    lu_table_template (width_template) {{
{width_template}
    }};
    {cell_str}
}}
        """)
    print("Library exported to cells.lib")
