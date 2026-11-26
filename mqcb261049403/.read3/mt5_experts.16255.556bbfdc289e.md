Calculation: D[n] = StochasticDiff(parameters, T1, n bars ago), where n=0 is the bar still forming and n>0 are completed bars
Long: D[1] < D[2] AND D[0] >= D[1]
Short: D[1] > D[2] AND D[0] <= D[1]
Exit: long, D[1] > D[2] AND D[0] > D[1]
Exit: short, D[1] < D[2] AND D[0] < D[1]