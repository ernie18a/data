Calculation: estimated volume delta = 2 * volume * (close - low) / max(high - low, minimum range) - volume
Long: estimated volume delta > 0 OR RSI(close, lookback) > upper threshold
Short: estimated volume delta <= 0 OR RSI(close, lookback) < lower threshold