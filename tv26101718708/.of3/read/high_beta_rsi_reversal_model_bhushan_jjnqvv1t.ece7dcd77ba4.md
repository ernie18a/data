Long: RSI(close, RSI lookback) < lower threshold AND volume > SMA(volume, volume lookback) * volume multiplier AND close > high[1]
Short: RSI(close, RSI lookback) > upper threshold AND volume > SMA(volume, volume lookback) * volume multiplier AND close < low[1]
Exit: long, close >= VWAP(close) OR close < low on latest long-signal bar
Exit: short, close <= VWAP(close) OR close > high on latest short-signal bar