manufacturing_grid_size = 0.005
pitch = manufacturing_grid_size * 40

wire_width = manufacturing_grid_size * 8
placement_grid_size = wire_width * 10
# offset should put wire in teh middle of the placement grid
wire_offset = placement_grid_size / 2 - wire_width / 2
wire_spacing = placement_grid_size

def to_n_decimals(f: float, n: int) -> str:
    a = str(f)
    if '.' in a:
        return a[:min(len(a)-1, n+1+a.index('.'))]


