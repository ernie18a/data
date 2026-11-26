Calculation: D = DecEMA(close, lookback, T1), evaluated on T1 bars with D[0] the last completed T1 bar
Long: D[1] < D[2] AND D[0] > D[1]
Short: D[1] > D[2] AND D[0] < D[1]
Exit: long, D[1] > D[2]
Exit: short, D[1] < D[2]