Calculation: Volume direction = 1 if close > close[1], -1 if close < close[1], otherwise 0
Calculation: Price momentum = (close - close[momentum lookback]) / max(EMA(abs(close - close[momentum lookback]), momentum lookback), positive floor)
Calculation: Volume pressure = volume direction * volume / max(EMA(volume, momentum lookback), positive floor)
Calculation: Volume-adjusted momentum = price momentum * (1 + volume influence * volume pressure / (1 + abs(volume pressure)))
Calculation: Volume momentum index = EMA(EMA(100 * EMA(volume-adjusted momentum, base smoothing lookback) / max(HIGHEST(abs(EMA(volume-adjusted momentum, base smoothing lookback)), normalization lookback), positive floor), VMI smoothing lookback), VMI smoothing lookback)
Long: Volume momentum index crosses above EMA(volume momentum index, signal lookback) AND volume momentum index < oversold threshold AND EMA(volume momentum index, signal lookback) < oversold threshold
Short: Volume momentum index crosses below EMA(volume momentum index, signal lookback) AND volume momentum index > overbought threshold AND EMA(volume momentum index, signal lookback) > overbought threshold