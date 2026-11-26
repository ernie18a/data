Calculation: Direction score(high, low, lookback) = sum(i=0..lookback-1, (1 if high[i] > high[i+1] else 0) - (1 if low[i] < low[i+1] else 0))
Long: Direction score(high, low, lookback1) > 0
Short: Direction score(high, low, lookback1) <= 0
Long: Direction score(high, low, lookback2, T1 forming bar) > 0 on chart bars
Short: Direction score(high, low, lookback2, T1 forming bar) <= 0 on chart bars