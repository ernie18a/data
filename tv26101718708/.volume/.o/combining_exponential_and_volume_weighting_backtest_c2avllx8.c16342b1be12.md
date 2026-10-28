Calculation: Volume-weighted EMA = EMA(close × volume, lookback) / EMA(volume, lookback)
Calculation: Oscillator = short-lookback volume-weighted EMA − long-lookback volume-weighted EMA, with the short lookback shorter than the long lookback
Calculation: Signal = EMA(Oscillator, smoothing lookback)
Calculation: Difference = Oscillator − Signal
Long: (Difference > 0 AND reverse is disabled) OR (Difference < 0 AND reverse is enabled) OR (Difference = 0 AND previous direction is long)
Short: (Difference < 0 AND reverse is disabled) OR (Difference > 0 AND reverse is enabled) OR (Difference = 0 AND previous direction is short)