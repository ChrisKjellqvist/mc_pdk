from src.liberty import cell as c

if __name__ == "__main__":
    print("Initializing cells")

    c.init_cells()

    # import sequential
    print("Exporting library")
    c.export_lib()
