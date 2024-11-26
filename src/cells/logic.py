from src.libgen import cell as c, grammar as gr
from src.libgen.cell import InputPin, OutputPin
from src.libgen.grammar import alphabet_input
from src.libgen.layout import Layout


def declare_logical_cells():
    # OR gate
    def j(l):
        return " ".join(l)

    def get_or_combos(up_to):
        for n_inputs in range(2, up_to + 1):
            # gonna be 2 * n_inputs - 1 wide
            left = n_inputs // 2
            right = n_inputs - left
            topup = j("e" * (left * 2 - 1)) + " Yw " + j("e" * (right * 2 - 1))
            topdown = j("g" * (n_inputs * 2 - 1))
            midupneg = j("e" * (left * 2 - 1)) + " mt " + j("e" * (right * 2 - 1))
            middownneg = j("w" * (left * 2 - 1)) + " s " + j("w" * (right * 2 - 1))
            miduppos = j("e" * (left * 2 - 1)) + " w " + j("e" * (right * 2 - 1))
            middownpos = j("w" * (left * 2 - 1)) + " g " + j("w" * (right * 2 - 1))
            inpup = list(alphabet_input[:n_inputs])
            inpdown = j("g" * (2 * n_inputs - 1))
            connup = j("e" * (2 * n_inputs - 1))
            inpup = "w ".join(inpup) + "w"
            ilist = []
            for i in range(n_inputs):
                ilist.append(c.InputPin(name=alphabet_input[i],
                                        is_clock=False))
            for i in range(n_inputs):
                ofun = []
                conn = ""
                for k in range(i):
                    conn += "ub1"
                    ofun.append(f"{alphabet_input[k]}")
                    if k != n_inputs - 1:
                        conn += " g "
                for k in range(i, n_inputs):
                    conn += "dt"
                    ofun.append(f"!{alphabet_input[k]}")
                    if k != n_inputs - 1:
                        conn += " g "
                c.Cell(name=f"NORN{n_inputs}_{i}",
                       cell_type=c.COMBINATIONAL,
                       delay=2,
                       area=4 * (2 * n_inputs - 1),
                       ipins=ilist,
                       opins=[c.OutputPin(name="Y", f=f"!({'+'.join(ofun)})")],
                       layout=Layout(accessible_layers=1,
                                     l=[f"{topup}\n{midupneg}\n{connup}\n{inpup}",
                                        f"{topdown}\n{middownneg}\n{conn}\n{inpdown}"]))
                c.Cell(name=f"ORN{n_inputs}_{i}",
                       cell_type=c.COMBINATIONAL,
                       delay=1,
                       area=4 * (2 * n_inputs - 1),
                       ipins=ilist,
                       opins=[c.OutputPin(name="Y", f=f"{'+'.join(ofun)}")],
                       layout=Layout(accessible_layers=1,
                                     l=[f"{topup}\n{miduppos}\n{connup}\n{inpup}",
                                        f"{topdown}\n{middownpos}\n{conn}\n{inpdown}"]))
    # # INV
    c.Cell("INV",
           c.COMBINATIONAL,
           delay=1,
           area=4,
           ipins=[InputPin("A")],
           opins=[OutputPin("Y", "!A")],
           layout=Layout(accessible_layers=1,
                         l=["Yw\n"
                            "dt\n"
                            "s\n"
                            "Aw"]))

    c.Cell("NOR2_S",
           c.COMBINATIONAL,
           1, 12,
           ipins=[c.InputPin("A"),
                  c.InputPin("B")],
           opins=[OutputPin("Y", "!(A+B)")],
           layout=Layout(accessible_layers=1,
                         l=["e  Yw e\n"
                            "e  w  e\n"
                            "e  dt  e\n"
                            "Aw s  Bw"]))
    c.Cell("NOR3_S",
           c.COMBINATIONAL,
           1, 12,
           ipins=[c.InputPin("A"),
                  c.InputPin("B"),
                  c.InputPin("C")],
           opins=[OutputPin("Y", "!(A+B+C)")],
           layout=Layout(accessible_layers=1,
                         l=["e  Yw  e\n"
                            "e  dt  e\n"
                            "Aw s  Bw\n"
                            "e  Cw  e"]))

    get_or_combos(8)

    c.Cell("MUX2",
           c.COMBINATIONAL,
           delay=4,
           area=20,
           ipins=[InputPin("A"), InputPin("B"), InputPin("S")],
           opins=[OutputPin("Y", "A*S + B*!S")],
           layout=Layout(accessible_layers=1,
                         l=[f" e  e mt Yw mt\n"
                            f" e  e dt  g dt\n"
                            f" e  e  s  g  g \n"
                            f"Sw  e Bw  e Aw",

                            f"dt  w  s  g  s\n"
                            f" s  e  w  e  w\n"
                            f" w  w rb  w  w\n"
                            f" g  g  g  g  g"]))

    c.Cell("BUF",
           c.COMBINATIONAL,
           delay=0,
           area=12,
           ipins=[InputPin("A")],
           opins=[OutputPin("Y", "A")],
           layout=Layout(accessible_layers=1,
                         l=["e Yw e\n"
                            "e w e\n"
                            "e ub e\n"
                            "e Aw e"]))
    c.Cell("XOR",
           c.COMBINATIONAL,
           delay=3,
           area=20,
           ipins=[InputPin("A"),
                  InputPin("B")],
           opins=[OutputPin("Y", "!((A*B)+(!A*!B))")],
           layout=Layout(1, ["e e w s w\n"
                             "e e ut dt ut\n"
                             "Yw mt s dt s\n"
                             "e e Aw s Bw",

                             "e e g e g\n"
                             "e e e w e\n"
                             "g s w w e\n"
                             "e e g e g"]))
