Calculation: DEMA MACD = DEMA(close, shorter lookback) - DEMA(close, longer lookback) - DEMA(DEMA(close, shorter lookback) - DEMA(close, longer lookback), signal lookback)
Long: DEMA MACD > 0 OR (RSI(close, lookback)[1] < lower threshold AND RSI(close, lookback) > lower threshold)
Short: DEMA MACD < 0 OR (RSI(close, lookback)[1] > upper threshold AND RSI(close, lookback) < upper threshold)