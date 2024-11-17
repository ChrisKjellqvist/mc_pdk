import math

# https://en.wikipedia.org/wiki/Electrical_resistivity_and_conductivity
# rho = RA/l
# R = resistance of wire
# A = cross sectional area
# l = length of wire
# https://en.wikipedia.org/wiki/Telegrapher's_equations#Lossless_transmission
# v = 1/sqrt(LC), where L is inductance and C is capacitance of the wire

# my education did not prepare me for this
# Let's keep it simple and use the equations from here
# https://courses.cs.washington.edu/courses/cse467/04wi/handouts/HighSpeedSignaling.pdf
# V_out(t) = V_in(1-e^(-t/RC))
# We're going to assume perfect voltage threshold: 50/50 for both rise and fall
# So we want to solve for 1-e^(-t/RC)=0.5
# 0.5=e^(-t/RC)
# -ln(2)=-t/RC
# ln(2)=t/RC
# We want to choose RC s.t. a signal propagates 16 blocks in one tick (t=1)
# The capacitance is a function of the voltage and wire dimensions

# https://user.engineering.uiowa.edu/~vlsi1/notes/lect14-wires.pdf
# ^ capacitance of a lone wire
eps_ox = 0.0885 * 3.9 # femtoFarads
# If we have perfect switching theshold at 50/50, then we compute RC=1/ln(2) for wire_length=15
# so that the placer will consider a wire of length 16 with delay=1tick
C_wire_15l = eps_ox * 15 * (1+0.77+1.06+1)
R_wire_15l = C_wire_15l / math.log(2)

# rho * l/A = R
rho_wire = R_wire_15l / 15


def gen_cap(n_layers: int, ofile: str):
    # all layers are the same
    with open(ofile, 'w') as f:
        f.write("NominalTemperature 100\nPROCESS_VARIATION ...\n")
        for i in range(1, n_layers+1):
            f.write(f"""
LAYER M{i}
    MinWidth    1
    Thickness   1
    TopWidth    1
    BottomWidth 1
    WidthDev    0
    Rho
        RhoWidths   1
        RhoSpacings 0.1 100
        RhoValues   {rho_wire} 
                    {rho_wire}
END

LAYER VIA{i}
    TopLayer    M{i+1}
    BottomLayer M{i}
    ThermalC1   0.0001
    ThermalC2   0.0001
    Resistance  {R_wire_15l}
END
""")
        f.write("""END_PROCESS_VARIATION\n\nBASIC_CAP_TABLE ...\n""")
        for i in range(1, n_layers+1):
            f.write(f"""M{i}
width(um) space(um) Ctot(Ff/um) Cc(Ff/um) Carea(Ff/um) Cfrg(Ff/um)
1 100 0.0001 0.0001 0.0001 0.0001
""")
        f.write("""END_BASIC_CAP_TABLE\n""")


if __name__ == "__main__":
    gen_cap(9, "cap.captable")