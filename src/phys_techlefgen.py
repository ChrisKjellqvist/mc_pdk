
if __name__ == "__main__":
    ofile = "test.lef"
    n_layers = 9
    with open(ofile, "w") as f:
        f.write("""VERSION 5.6 ;
BUSBITCHARS "[]" ;
DIVIDERCHAR "/" ;

UNITS
    DATABASE MICRONS 1
END UNITS

MANUFACTURINGGRID 100 ;
PROPERTYDEFINITIONS
    LAYER LEF57_SPACING STRING ;
    LAYER LEF57_MINSTEP STRING ;
END PROPERTYDEFINITIONS
""")
        def write_layer(q, i, do_via):
            q.write(f"""
LAYER M{i}
    TYPE ROUTING
    DIRECTION {"HORIZONTAL" if i % 2 == 0 else "VERTICAL"} ;
    PITCH 1 ;
    WIDTH 1 ;
    SPACING 100 ;
    AREA 200 ; # 1x100 wire is minarea
    
    PROPERTY LEF57_SPACING "SPACING 100 ENDOFLINE 1 WITHIN 1 PARALLELEDGE 1 WITHIN 1 ;" ;
    
END M{i}
""" + f"""
LAYER VIA{i}
    TYPE CUT ;
    SPACING 100 ;
    PROPERTY LEF57_SPACING "SPACING 100 PARALLELOVERLAP ;" ;
END VIA{i}

VIA VIA{i}{i+1} Default
    LAYER M{i+1} ;
        RECT -1 -1 1 1 ;
    LAYER VIA{i} ;
        RECT -1 -1 1 1 ;
    LAYER M{i} ;
        RECT -1 1 1 1 ;
END VIA{i}{i+1}

VIARULE VIAGEN{i} GENERATE
    LAYER{i+1} ;
        ENCLOSURE 1 1 ;
        WIDTH 1 TO 1 ;
    LAYER VIA{i} ;
        ENCLOSURE 1 1 ;
        WIDTH 1 TO 1 ;
    LAYER{i} ;
        ENCLOSURE 1 1 ;
        WIDTH 1 TO 1 ;
END VIDAGEN{i}

SITE mc_site
    SIZE 1 BY 1 ;
    CLASS CORE ;
    SYMMETRY Y ;
END mc_site


        
""" if do_via else "")

        for i in range(1, n_layers + 1):
            write_layer(f, i, i < n_layers)

