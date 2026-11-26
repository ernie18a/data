Calculation: swing direction = false when low = lowest(low, swing lookback), else true when high = highest(high, swing lookback), else prior swing direction (initially false)
Long: swing direction = false AND swing direction[1] = true
Short: swing direction = true AND swing direction[1] = false