Long: volume > SMA(volume, volume lookback) * volume multiplier AND RSI(close, RSI lookback) <= oversold threshold
Exit: Long, low <= entry price * (1 - stop loss / 100)
Exit: Long, high >= entry price * (1 + target 1 / 100)
Exit: Long, high >= entry price * (1 + target 2 / 100)
Exit: Long, high >= entry price * (1 + target 3 / 100)
Exit: Long, high >= entry price * (1 + target 4 / 100)
Exit: Long, high >= entry price * (1 + target 5 / 100)