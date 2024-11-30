from mc_pdk.libgen.route import Route

"""
We allow routing on 
"""

def twocolor(route_set: list[Route]):
    def opp(q):
        return 1 if q == 0 else 0

    sq2Ridx = dict()
    for r in route_set:
        for loc in r.route:
            # ensure there is not a metal short
            assert sq2Ridx.get(loc) is None
            sq2Ridx[loc] = r.name

    csp = set()
    for r in route_set:
        for x, y in r.route:
            for dx, dy in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
                rx = x + dx
                ry = y + dy
                nloc = (rx, ry)
                nidx = sq2Ridx.get(nloc)
                if nidx is not None and nidx != r.name:
                    csp.add((r.name, nidx))
    # print(csp)
    # see if we can satisfy
    settings = dict()
    for r in route_set:
        if settings.get(r.name) is not None:
            continue
        constraints = list(map(lambda x: x[1], filter(lambda x: x[0] == r.name, csp)))
        # print(f"constraints on {r.name}: {list(constraints)}")
        must_set = -1
        implies = set()
        for c in constraints:
            cmap = settings.get(c)
            # print(f"Setting of {c} is currently {cmap}")
            if cmap is not None:
                if must_set == -1:
                    must_set = opp(cmap)
                else:
                    if must_set != opp(cmap):
                        print("UNSATISFIABLE")
                        return None
            else:
                implies.add(c)
        if must_set == -1:
            settings[r.name] = 0
            must_set = 0
        else:
            settings[r.name] = must_set
        for imply in implies:
            # print(f"Set {r.name} to {must_set}, so setting {imply} to {opp(must_set)}")
            settings[imply] = opp(must_set)

    # double check CSP
    for x, y in csp:
        if settings[x] == settings[y]:
            # print(settings)
            print("UNSATISFIABLE")
            return None

    return settings


if __name__ == "__main__":
    print("Test: Should be unsatisfiable")
    """
    CCCC
    AABB
     AB
    """
    route_set = [Route("A", [(1, 0), (1, 1), (0, 1)]),
                 Route("B", [(2, 0), (2, 1), (3, 1)]),
                 Route("C", [(0, 2), (1, 2), (2, 2), (3, 2)])]
    print(twocolor(route_set))

    print("Test: Should be satisfiable with A: 0, B: 1, C: 0")
    """
    CCCC
    
    AABB
     AB
     """
    route_set2 = [Route("A", [(1, 0), (1, 1), (0, 1)]),
                  Route("B", [(2, 0), (2, 1), (3, 1)]),
                  Route("C", [(0, 3), (1, 3), (2, 3), (3, 3)])]
    print(twocolor(route_set2))
