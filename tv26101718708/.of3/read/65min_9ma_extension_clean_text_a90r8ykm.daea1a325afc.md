Calculation: price extension percentage = ((close - SMA(close, lookback, T1, still-forming bar, sampled on chart bars)) / SMA(close, lookback, T1, still-forming bar, sampled on chart bars)) * 100
Long: price extension percentage <= -threshold
Short: price extension percentage >= threshold