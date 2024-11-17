from src.global_constants import *

if __name__ == "__main__":
    ofile = "test.lef"
    n_layers = 9
    vSz = int(np.sqrt(min_spacing)+1)
    with open(ofile, "w") as f:
        f.write(f"""VERSION 5.6 ;
BUSBITCHARS "[]" ;
DIVIDERCHAR "/" ;

UNITS
    DATABASE MICRONS 1
END UNITS

MANUFACTURINGGRID {grid_size} ;
PROPERTYDEFINITIONS
    LAYER LEF57_SPACING STRING ;
    LAYER LEF57_MINSTEP STRING ;
END PROPERTYDEFINITIONS

""")
        def write_layer(q, i, do_via):
            q.write(f"""
LAYER M{i}
    TYPE ROUTING
    DIRECTION {"HORIZONTAL" if i % 2 == 1 else "VERTICAL"} ;
    PITCH {grid_size} ;
    WIDTH 1 ;
    SPACING {min_spacing} ;
    AREA {min_spacing} ; # 1xmin_space wire is minarea (signifying a dot - needed for vias)
    
    PROPERTY LEF57_SPACING "SPACING {min_spacing} ENDOFLINE {grid_size} WITHIN {grid_size} PARALLELEDGE {grid_size} WITHIN {grid_size} ;" ;
    
END M{i}
""" + f"""
LAYER VIA{i}
    TYPE CUT ;
    SPACING {min_spacing} ;
    PROPERTY LEF57_SPACING "SPACING {min_spacing} PARALLELOVERLAP ;" ;
END VIA{i}

VIA VIA{i}{i+1} Default
    LAYER M{i+1} ;
        RECT -{vSz} -{vSz} {vSz} {vSz} ;
    LAYER VIA{i} ;
        RECT -1 -1 1 1 ;
    LAYER M{i} ;
        RECT -{vSz} -{vSz} {vSz} {vSz} ;
END VIA{i}{i+1}

VIARULE VIAGEN{i} GENERATE
    LAYER{i+1} ;
        ENCLOSURE {vSz} {vSz} ;
        WIDTH {vSz} TO {vSz} ;
    LAYER VIA{i} ;
        ENCLOSURE {vSz} {vSz} ;
        WIDTH {vSz} TO {vSz} ;
    LAYER{i} ;
        ENCLOSURE {vSz} {vSz} ;
        WIDTH {vSz} TO {vSz} ;
END VIDAGEN{i}

SITE mc_site
    SIZE 1 BY 1 ;
    CLASS CORE ;
    SYMMETRY Y ;
END mc_site


        
""" if do_via else "")

        for i in range(0, n_layers + 1):
            write_layer(f, i, i < n_layers)

