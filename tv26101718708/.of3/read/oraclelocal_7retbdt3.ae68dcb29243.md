Calculation: Relative volume = volume / SMA(volume, relative-volume lookback)
Calculation: EMA percentage change = (EMA(close, trend EMA lookback) - EMA(close, trend EMA lookback)[1]) / EMA(close, trend EMA lookback)[1] * 100
Long: position side = flat AND close > EMA(close, trend EMA lookback) AND RSI(close, momentum RSI lookback) > long-entry RSI threshold AND Relative volume >= relative-volume threshold AND EMA percentage change > 0
Short: position side = flat AND close < EMA(close, trend EMA lookback) AND RSI(close, momentum RSI lookback) < short-entry RSI threshold AND Relative volume >= relative-volume threshold AND EMA percentage change < 0
Exit: long, close < EMA(close, trend EMA lookback) OR RSI(close, momentum RSI lookback) crosses below RSI exit threshold
Exit: short, close > EMA(close, trend EMA lookback) OR RSI(close, momentum RSI lookback) crosses above RSI exit threshold