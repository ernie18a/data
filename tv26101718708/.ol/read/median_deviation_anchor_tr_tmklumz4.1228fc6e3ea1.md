Calculation: Median anchor = nearest-rank percentile of a moving average of close over a lookback
Calculation: Raw oscillator = if close > median anchor − ATR band AND close ≥ median anchor + standard deviation, ((close − median anchor) / ATR band) × 100; else if close < median anchor + ATR band AND close ≤ median anchor − standard deviation, ((close − median anchor) / ATR band) × 100; otherwise 0; ATR band = ATR × multiplier; standard deviation = standard deviation of the median anchor over a lookback
Calculation: Oscillator = clamp the EMA of the raw oscillator to [−2000, 2000]
Long: oscillator > upper threshold
Short: oscillator < lower threshold