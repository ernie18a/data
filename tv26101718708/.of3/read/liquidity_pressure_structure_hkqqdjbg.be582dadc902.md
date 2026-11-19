Calculation: latest confirmed swing high = most recent confirmed Pivot High(high, swing lookback, swing lookback)
Calculation: latest confirmed swing low = most recent confirmed Pivot Low(low, swing lookback, swing lookback)
Calculation: smoothed pressure = EMA((((2 * (high = low ? 0 : (close - low) / (high - low)) - 1) + sign(close - open)) / 2), pressure smoothing length)
Calculation: relative volume = SMA(volume, volume average lookback) > 0 ? volume / SMA(volume, volume average lookback) : 0
Calculation: bullish setup = (latest confirmed swing low is defined AND low < latest confirmed swing low AND close > latest confirmed swing low AND smoothed pressure > 0 AND close > open) OR (latest confirmed swing high is defined AND close > latest confirmed swing high AND smoothed pressure > 0 AND relative volume >= volume expansion threshold)
Calculation: bearish setup = (latest confirmed swing high is defined AND high > latest confirmed swing high AND close < latest confirmed swing high AND smoothed pressure < 0 AND close < open) OR (latest confirmed swing low is defined AND close < latest confirmed swing low AND smoothed pressure < 0 AND relative volume >= volume expansion threshold)
Long: smoothed pressure > pressure color threshold
Short: smoothed pressure < -pressure color threshold
Long: bullish setup AND NOT bullish setup[1]
Short: bearish setup AND NOT bearish setup[1]