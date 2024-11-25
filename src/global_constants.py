manufacturing_grid_size = 0.005
pitch = manufacturing_grid_size * 40


def to_n_decimals(f: float, n: int) -> str:
    a = str(f)
    if '.' in a:
        return a[:min(len(a)-1, n+1+a.index('.'))]


def to_n_decimals_flt(f: float, n: int) -> float:
    return float(to_n_decimals(f, n))


wire_width = manufacturing_grid_size * 8
placement_grid_size = to_n_decimals_flt(wire_width * 10, 4)
# offset should put wire in teh middle of the placement grid
wire_offset = to_n_decimals_flt(placement_grid_size / 2 - wire_width / 2, 4)
wire_spacing = to_n_decimals_flt(placement_grid_size, 4)

