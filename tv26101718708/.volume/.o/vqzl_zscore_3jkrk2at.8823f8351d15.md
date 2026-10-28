Calculation: Filtered OHLC = apply the selected moving average to open, high, low, and close using the same smoothing lookback.
Calculation: VQI = let pClose be the prior bar’s filtered close, trueRange = max(filtered high, filtered close) − min(filtered low, pClose), and range = filtered high − filtered low. Set vqi = ((filtered close − pClose) / trueRange + (filtered close − filtered open) / range) / 2 when both ranges are nonzero, otherwise 0. Let raw = abs(vqi) × ((filtered close − pClose) + (filtered close − filtered open)) / 2. VQI = raw if abs(raw) > 1; otherwise raw × 10 if abs(raw) × 10 > 1; otherwise raw.
Calculation: VQZL Z-score = (VQI − SMA(VQI, lookback)) / standard deviation(VQI, lookback).
Long: VQZL Z-score > 0
Short: VQZL Z-score < 0