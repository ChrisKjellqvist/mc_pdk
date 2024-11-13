import lib_cell as c

if __name__ == "__main__":
    print("Initializing cells")

    c.init_cells()

    import logic
    # import sequential
    print("Exporting library")
    c.export_lib()
