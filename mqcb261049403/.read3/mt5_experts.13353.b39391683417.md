Calculation: M = Zero Lag X10 moving average(close, lookback) on T1 bars, read on chart bars with M[0] from the still-forming T1 bar
Long: M > M[1]
Short: M < M[1]
Long: M[1] < M[2] AND M > M[1]
Short: M[1] > M[2] AND M < M[1]
Exit: long, M[1] > M[2]
Exit: short, M[1] < M[2]