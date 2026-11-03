Calculation: Smoothed OHLC = apply the same selected moving average and lookback to each OHLC field
Calculation: VQI = if smoothed high differs from smoothed low and true range is nonzero, 0.5 * ((smoothed close − prior smoothed close) / true range + (smoothed close − smoothed open) / (smoothed high − smoothed low)); otherwise 0, where true range = max(smoothed high, smoothed close) − min(smoothed low, prior smoothed close)
Calculation: Adjusted VQI = let x = abs(VQI) * (smoothed close − prior smoothed close + smoothed close − smoothed open) / 2; use x if abs(x) > 1, else 10x if 10 * abs(x) > 1, else x
Calculation: VQZL Z-score = (current adjusted VQI − its simple moving average) / its standard deviation, using the same lookback for both
Long: VQZL Z-score > 0
Short: VQZL Z-score < 0