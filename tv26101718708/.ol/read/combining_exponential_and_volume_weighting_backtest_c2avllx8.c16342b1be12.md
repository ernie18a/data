Calculation: Volume-weighted exponential average price = EMA(volume × close) / EMA(volume)
Calculation: Volume-weighted MACD = short-lookback volume-weighted exponential average price − long-lookback volume-weighted exponential average price; the short lookback is shorter than the long lookback
Calculation: Signal line = EMA(volume-weighted MACD, smoothing lookback)
Calculation: Histogram = volume-weighted MACD − signal line
Long: (reverse trading disabled AND Histogram > 0) OR (reverse trading enabled AND Histogram < 0)
Short: (reverse trading disabled AND Histogram < 0) OR (reverse trading enabled AND Histogram > 0)