Calculation: H = ColorXtrix histogram(close, parameters) calculated on T1 bars and read on chart bars; H[0] is the T1 bar still forming, H[1+] are completed T1 bars
Long: H[0] >= 0 OR (H[0] > H[1] AND H[1] < H[2])
Short: H[0] < 0 OR (H[0] < H[1] AND H[1] > H[2])
Exit: long, H[1] > H[2]
Exit: short, H[1] < H[2]