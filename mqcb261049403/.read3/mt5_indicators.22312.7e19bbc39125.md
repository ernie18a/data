Calculation: Skyscraper step = sensitivity × mean(highest(ATR(ATR lookback), range lookback), lowest(ATR(ATR lookback), range lookback)), rounded down to minimum price increments
Calculation: Skyscraper direction = -1 if close < previous lower threshold, +1 if close > previous upper threshold, otherwise previous direction; initialize at 0
Calculation: Upper threshold = candidate if Skyscraper direction > 0, otherwise min(candidate, previous upper threshold), where candidate = (previous direction > 0 ? low : close) + barrier width × Skyscraper step; initialize at close
Calculation: Lower threshold = max(candidate, previous lower threshold) if Skyscraper direction > 0, otherwise candidate, where candidate = (previous direction > 0 ? high : close) - barrier width × Skyscraper step; initialize at close
Long: close > previous upper threshold
Short: close < previous lower threshold