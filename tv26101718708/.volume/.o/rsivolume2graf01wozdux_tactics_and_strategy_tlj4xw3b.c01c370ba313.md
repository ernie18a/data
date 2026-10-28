Calculation: Volume-weighted average close = EMA(close × volume, longer lookback) / EMA(volume, longer lookback)
Calculation: Volume RSI = RSI(volume-weighted average close, same longer lookback)
Long: RSI(close, shorter lookback) < lower RSI threshold (100 − upper RSI threshold)
Short: RSI(close, shorter lookback) > upper RSI threshold OR Volume RSI ≥ critical volume RSI level