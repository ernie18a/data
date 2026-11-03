Calculation: Cumulative signed volume = cumulative sum of volume when close >= open, and negative volume otherwise
Calculation: Normalized z-score = ((value - SMA(value, lookback)) - SMA(raw, normalization)) / standard deviation(raw, normalization), where raw = value - SMA(value, lookback)
Calculation: Edge = normalized z-score of cumulative signed volume - normalized z-score of close
Long: Edge > threshold
Short: Edge < -threshold