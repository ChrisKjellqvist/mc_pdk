from src.liberty import cell as c, grammar as gr
from src.liberty.cell import InputPin, OutputPin, Layout


def declare_logical_cells():
    # OR gate
    def gen_orn(n_inputs):
        assert 7 >= n_inputs >= 2
        input_wires = ' w '.join([f'{nm}w' for nm in gr.alphabet_input[:n_inputs]])
        c.Cell("OR%d" % n_inputs,
               c.COMBINATIONAL,
               0,
               3 * (2 * n_inputs - 1),
               [InputPin(gr.alphabet_input[i]) for i in range(n_inputs)],
               [OutputPin("Y", "+".join(gr.alphabet_input[:n_inputs]))],
               layout=Layout([f"""e Yw e {'e ' * max(0, (2 * (n_inputs - 1) - 1))} 
                          w  w w {'w ' * max(0, (2 * (n_inputs - 1) - 1))}
                          {input_wires}"""]))
        for i in range(1, n_inputs):
            f = list(gr.alphabet_input[:n_inputs])
            for j in range(i):
                f[j] = "!" + f[j]
            # input wires are the same, but now we have two rows of target+torch to account
            # we'll handle each layer individually
            l1 = "Yw" + " e" * (2 * n_inputs - 1)
            l2 = "w".join("w" * n_inputs)
            l3 = []
            l4 = []
            l5 = []
            for j in range(n_inputs):
                if j < i:
                    l3.append("dt")
                    l4.append("s")
                else:
                    l3.append("w")
                    l4.append("w")
                l5.append(gr.alphabet_input[j] + "w")
            l3 = " w ".join(l3)
            l4 = " e ".join(l4)
            l5 = " e ".join(l5)
            c.Cell(f"OR{n_inputs}_{i}",
                   c.COMBINATIONAL,
                   delay=1,
                   area=5 * (2 * n_inputs - 1),
                   ipins=[InputPin(gr.alphabet_input[i]) for i in range(n_inputs)],
                   opins=[OutputPin("Y", "+".join(f))],
                   layout=Layout([f"{l1}\n{l2}\n{l3}\n{l4}\n{l5}"]))


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
            lins = n_inputs // 2
            rins = n_inputs - lins
            l1 = (' e '.join('e' * lins)) + ' Ydt ' + (' e '.join('e' * rins))
            l2 = (' w '.join('w' * lins)) + ' s ' + (' w '.join('w' * rins))
            l3 = []
            l4 = []
            l5 = []
            for j in range(n_inputs):
                if j < i:
                    l3.append('dt')
                    l4.append('s')
                else:
                    l3.append('w')
                    l4.append('w')
                l5.append(f'{gr.alphabet_input[j]}w')

            l3 = ' e '.join(l3)
            l4 = ' e '.join(l4)
            l5 = ' e '.join(l5)
            rows = [l1, l2, l3, l4, l5]
            c.Cell(f"NOR{n_inputs}_{i}",
                   c.COMBINATIONAL,
                   delay=2,
                   area=5 * (2 * n_inputs - 1),
                   ipins=[InputPin(gr.alphabet_input[q]) for q in range(n_inputs)],
                   opins=[OutputPin("Y", f"!({'*'.join(f)})")],
                   layout=Layout(['\n'.join(rows)]))


    # ANDS gate - AND "sparse"
    # yikes
    # c.Cell("AND2", c.COMBINATIONAL, 2, 18, [InputPin("A"), InputPin("B")], [OutputPin("Y", "A*B")])

    # # INV
    c.Cell("INV",
           c.COMBINATIONAL,
           delay=1,
           area=9,
           ipins=[InputPin("A")],
           opins=[OutputPin("Y", "!A")],
           layout=Layout(["e Ydt e\ne s e\ne Aw e"]))

    # NAND
    c.Cell("NAND2",
           c.COMBINATIONAL,
           delay=2,
           area=9,
           ipins=[InputPin("A"), InputPin("B")],
           opins=[OutputPin("Y", "!(A*B)")],
           layout=Layout(["dt Yw dt\ns e s\nAw e Bw"]))

    c.Cell("NOR2_S",
           c.COMBINATIONAL,
           1, 9,
           ipins=[c.InputPin("A"),
                  c.InputPin("B")],
           opins=[OutputPin("Y", "!(A+B)")],
           layout=Layout(["e  Yw  e\n"
                          "e  dt  e\n"
                          "Aw s  Bw"]))
    c.Cell("NOR3_S",
           c.COMBINATIONAL,
           1, 12,
           ipins=[c.InputPin("A"),
                  c.InputPin("B"),
                  c.InputPin("C")],
           opins=[OutputPin("Y", "!(A+B+C)")],
           layout=Layout(["e  Yw  e\n"
                          "e  dt  e\n"
                          "Aw s  Bw\n"
                          "e  Cw  e"]))

    # OR2,3,4,5
    for i in range(5):
        gen_orn(i + 2)
        gen_norn(i + 2)

    c.Cell("MUX2",
           c.COMBINATIONAL,
           delay=4,
           area=20,
           ipins=[InputPin("A"), InputPin("B"), InputPin("S")],
           opins=[OutputPin("Y", "A*S + B*!S")],
           layout=Layout([f" e  e mt Yw mt\n"
                         f" e  e dt  g dt\n"
                         f" e  e  s  g  g \n"
                         f"Sw  e Bw  e Aw",

                         f"dt  w  s  g  s\n"
                         f" s  e  w  e  w\n"
                         f" w  w rb  w  w\n"
                         f" g  g  g  g  g"]))

    c.Cell("XOR",
           c.COMBINATIONAL,
           delay=3,
           area=20,
           ipins=[InputPin("A"), InputPin("B")],
           opins=[OutputPin("Y", "!((A*B)+(!A*!B))")],
           layout=Layout(["e   e  "])
           )
    c.Cell("BUF",
           c.COMBINATIONAL,
           delay=0,
           area=9,
           ipins=[InputPin("A")],
           opins=[OutputPin("Y", "A")],
           layout=Layout(["e Yw e\n"
                          "e ub e\n"
                          "e Aw e"]))
