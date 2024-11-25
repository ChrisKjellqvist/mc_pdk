manufacturing_grid_size = 0.005
pitch = manufacturing_grid_size * 40

wire_width = manufacturing_grid_size * 8
wire_offset = wire_width / 2
wire_spacing = wire_width * 2

def to_n_decimals(f: float, n: int) -> str:
    a = str(f)
    if '.' in a:
        return a[:min(len(a)-1, n+1+a.index('.'))]


