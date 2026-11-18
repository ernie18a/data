Calculation: direction state = 1 if trigger source > SMA(source from the still-forming T1 bar, lookback) calculated on chart bars, -1 if trigger source < that SMA, otherwise the previous direction state (initially 0)
Long: direction state = 1 AND direction state != direction state[1]
Short: direction state = -1 AND direction state != direction state[1]