manufacturing_grid_size = 0.005
pitch = manufacturing_grid_size * 40


def to_n_decimals(f: float, n: int) -> str:
    a = str(f)
    if '.' in a:
        return a[:min(len(a), n+1+a.index('.'))]


def to_n_decimals_flt(f: float, n: int) -> float:
    return float(to_n_decimals(f, n))


wire_width = manufacturing_grid_size * 8
placement_grid_size = to_n_decimals_flt(manufacturing_grid_size * 100, 4)
# offset should put wire in teh middle of the placement grid
wire_offset = to_n_decimals_flt(placement_grid_size / 2 - wire_width / 2, 4)
wire_spacing = to_n_decimals_flt(placement_grid_size - wire_width, 4)

print(f"""Wire width: {wire_width}
Placement grid size: {placement_grid_size}
Wire_off: {wire_offset}
wire_space: {wire_spacing}""")

