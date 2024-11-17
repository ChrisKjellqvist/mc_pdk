alphabet_input = "ABCDEFGHIJKLMNOPQRST"
alphabet_output = "YZXWVU"

def check_function(f: str):
    """
    A pin function should have only the operators * and +
    () are allowed for grouping
    The inputs should be single uppercase letters

    Here's the BNF - whitespace is ignored

    function = expr
    expr = nterm op nterm
         | nterm

    nterm = term
          | !term

    term = ( expr )
         | identifier

    identifier = [A-Z]
               | CLK

    op = *
       | +
    :return: assert if the function is not valid
    """
    fstr = f

    def expr():
        global fstr
        nterm()
        if len(fstr) > 0:
            op()
            nterm()

    def nterm():
        global fstr
        if fstr[0] == "!":
            fstr = fstr[1:]
        term()

    def term():
        global fstr
        if fstr[0] == "(":
            fstr = fstr[1:]
            expr()
            assert fstr[0] == ")"
            fstr = fstr[1:]
        else:
            assert fstr[0].isupper()
            if len(fstr) >= 3 and fstr[:3] == "CLK":
                fstr = fstr[3:]
            else:
                fstr = fstr[1:]

    def op():
        global fstr
        assert fstr[0] in "*+"
        fstr = fstr[1:]