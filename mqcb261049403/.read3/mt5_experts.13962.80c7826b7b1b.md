Calculation: H = XKRI_Histogram(T1) on T1 bars; H[0] is the bar still forming, H[1] and H[2] are the last completed bars
Long: long entries enabled AND H[1] < H[2] AND H[0] > H[1]
Short: short entries enabled AND H[1] > H[2] AND H[0] < H[1]
Exit: long, long exits enabled AND H[1] > H[2]
Exit: short, short exits enabled AND H[1] < H[2]