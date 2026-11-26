Calculation: I = i-CAi(applied price, T1), evaluated on T1 bars at close; I[0] is the last completed bar.
Long: I[1] < I[2] AND I[0] >= I[1]
Short: I[1] > I[2] AND I[0] <= I[1]
Exit: short, I[1] < I[2]
Exit: long, I[1] > I[2]