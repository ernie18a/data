Calculation: Gaussian-smoothed price = the normalized weighted average of the current and preceding bars' prices, with weights proportional to exp(-9i²/(N+1)²), where i is the bar offset and N is the smoothing lookback.
Calculation: SR rate = 200 × (Gaussian-smoothed weighted close − lowest Gaussian-smoothed low in the lookback window) / (highest Gaussian-smoothed high − lowest Gaussian-smoothed low) − 100; use 0 when the denominator is 0. Weighted close = (high + low + 2 × close) / 4.
Long: SR rate > 0
Short: SR rate < 0