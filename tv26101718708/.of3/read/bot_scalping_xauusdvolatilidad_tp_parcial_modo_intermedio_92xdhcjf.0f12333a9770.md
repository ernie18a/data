Calculation: Relative volume = volume / SMA(volume, volume-average lookback)
Calculation: Stop distance = stop multiplier * ATR(ATR lookback)
Calculation: Target distance = target-to-stop multiplier * stop distance
Long: ATR(ATR lookback) > SMA(ATR(ATR lookback), ATR-average lookback) * volatility multiplier AND EMA(close, short EMA lookback) > EMA(close, medium EMA lookback) AND EMA(close, medium EMA lookback) > EMA(close, long EMA lookback) AND low <= EMA(close, short EMA lookback) AND RSI(close, RSI lookback) > long RSI threshold AND close > open AND Relative volume > volume threshold
Short: ATR(ATR lookback) > SMA(ATR(ATR lookback), ATR-average lookback) * volatility multiplier AND EMA(close, short EMA lookback) < EMA(close, medium EMA lookback) AND EMA(close, medium EMA lookback) < EMA(close, long EMA lookback) AND high >= EMA(close, short EMA lookback) AND RSI(close, RSI lookback) < short RSI threshold AND close < open AND Relative volume > volume threshold
Exit: long, low <= entry price - Stop distance at entry OR high >= entry price + Target distance at entry
Exit: short, high >= entry price + Stop distance at entry OR low <= entry price - Target distance at entry