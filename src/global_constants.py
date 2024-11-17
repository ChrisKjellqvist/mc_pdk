import numpy as np
grid_size = 5


def to_n_decimals(f: float, n: int) -> str:
    a = str(f)
    if '.' in a:
        return a[:min(len(a)-1, n+1+a.index('.'))]


min_spacing = to_n_decimals(grid_size * np.sqrt(2) + 1, 2)
