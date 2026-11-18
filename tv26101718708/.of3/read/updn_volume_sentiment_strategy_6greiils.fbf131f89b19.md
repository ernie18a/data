Calculation: volume sentiment oscillator = 100 * (R - Lowest(R, normalization lookback)) / (Highest(R, normalization lookback) - Lowest(R, normalization lookback)), where R = SMA(volume when close > close[1] else 0, volume lookback) / SMA(volume when close < close[1] else 0, volume lookback), and R is undefined when its denominator is zero
Long: volume sentiment oscillator <= long-entry threshold
Short: volume sentiment oscillator >= short-entry threshold
Exit: long, low <= entry price * (1 - stop-loss fraction) OR high >= entry price * (1 + stop-loss fraction * target R multiple)
Exit: short, high >= entry price * (1 + stop-loss fraction) OR low <= entry price * (1 - stop-loss fraction * target R multiple)