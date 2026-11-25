Calculation: Q = quadratic function of price bars over its lookback
Calculation: Short MA = MA(Q, shorter lookback)
Calculation: Long MA = MA(Q, longer lookback)
Short: Short MA[2] > Long MA[2] AND Short MA[1] < Long MA[1] AND Short MA[0] < Long MA[0] AND Short MA[2] > 0 AND Long MA[2] > 0 AND Q[1] <= 0 AND Q[0] < 0
Long: Short MA[2] < Long MA[2] AND Short MA[1] > Long MA[1] AND Short MA[0] > Long MA[0] AND Short MA[2] < 0 AND Long MA[2] < 0 AND Q[1] >= 0 AND Q[0] > 0
Short: Short MA[2] > Long MA[2] AND Short MA[1] < Long MA[1] AND Short MA[0] < Long MA[0] AND Q[2] >= Q[1]
Long: Short MA[2] < Long MA[2] AND Short MA[1] > Long MA[1] AND Short MA[0] > Long MA[0] AND Q[2] <= Q[1]
Exit: long, Short MA[2] - Long MA[2] > Short MA[1] - Long MA[1]
Exit: short, Short MA[2] - Long MA[2] > Short MA[1] - Long MA[1]