Calculation: nRes = EMA(volume * close, lookback) / EMA(volume, lookback)
Long: nRes < close[1]
Short: nRes > close[1]