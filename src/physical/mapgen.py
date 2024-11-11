def gen_map(n_layers: int, ofile: str):
    """
    Generate a map file
    :param n_layers: number of layers
    :param ofile: output file
    :return: None
    """
    idx = 0
    strs = []
    for i in range(1, n_layers+1):
        strs.append([f"M{i}", "NET, SPNET, VIA", f"{idx}", "0"])
        strs.append([f"VIA{i}", "VIA", f"{idx+1}", "0"])
        strs.append([f"M{i}", "PIN", f"{idx}", "0"])
        idx += 2

    spacing = []
    # align the columns by storing the required spacing for each cell in the spacing list
    for i in range(len(strs)):
        l = strs[i]
        ncols = []
        for col in range(len(l)):
            longest = max([len(s[col]) for s in strs])
            ncols.append(longest+2-len(l[col]))
        spacing.append(ncols)

    with open(ofile, "w") as f:
        # align the columns
        for i in range(len(strs)):
            l = strs[i]
            for col in range(len(l)):
                f.write(l[col] + " "*spacing[i][col])
            f.write("\n")


if __name__ == "__main__":
    gen_map(9, "map.map")
