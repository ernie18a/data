Calculation: Previous day high = high of the last completed bar on a higher, daily timeframe
Calculation: Previous day low = low of the last completed bar on a higher, daily timeframe
Calculation: Previous day midpoint = (previous day high + previous day low) / 2
Long: low <= previous day low
Short: high >= previous day high
Exit: long, high >= previous day midpoint
Exit: short, low <= previous day midpoint