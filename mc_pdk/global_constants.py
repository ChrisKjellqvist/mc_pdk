manufacturing_grid_size = 12.5
pitch = manufacturing_grid_size * 8


def to_n_decimals(f: float, n: int) -> str:
    a = str(f)
    if '.' in a:
        return a[:min(len(a), n+1+a.index('.'))]


def to_n_decimals_flt(f: float, n: int) -> float:
    return float(to_n_decimals(f, n))


wire_width = manufacturing_grid_size * 4
placement_grid_size = manufacturing_grid_size * 8
# offset should put wire in teh middle of the placement grid
wire_offset = to_n_decimals_flt(placement_grid_size / 2 - wire_width / 2, 4)
standard_cell_height = 4 * placement_grid_size

aggressive=False
if aggressive:
    wire_spacing_PARALLEL = to_n_decimals_flt(placement_grid_size - wire_width, 4)
    wire_spacing_EOL = to_n_decimals_flt(placement_grid_size*2 - wire_width, 4)
    wire_spacing_SAMENET = 0
else:
    wire_spacing_PARALLEL = wire_spacing_EOL = to_n_decimals_flt(placement_grid_size * 2 - wire_width, 4)
    wire_spacing_SAMENET = 0
    # wire_spacing_EOL = to_n_decimals_flt(placement_grid_size*2 - wire_width, 4)

print(f"""Wire width: {wire_width}
Placement grid size: {placement_grid_size}
Wire_off: {wire_offset}
wire_space: {wire_spacing_PARALLEL}
wire_space_eol: {wire_spacing_EOL}""")

