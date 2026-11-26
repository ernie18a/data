Calculation: H = OsHMA(applied price, parameters, T1, last completed bar)
Long: (H[1] > 0 AND H[0] <= 0) OR (H[1] < H[2] AND H[0] > H[1])
Short: (H[1] < 0 AND H[0] >= 0) OR (H[1] > H[2] AND H[0] < H[1])