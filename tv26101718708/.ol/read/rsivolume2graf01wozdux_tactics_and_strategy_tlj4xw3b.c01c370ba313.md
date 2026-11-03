Calculation: volume-weighted close = EMA(close × volume, longer RSI lookback) / EMA(volume, longer RSI lookback)
Long: RSI(close, shorter lookback) < lower RSI threshold
Short: RSI(close, shorter lookback) > upper RSI threshold OR RSI(volume-weighted close, longer lookback) ≤ critical volume RSI threshold