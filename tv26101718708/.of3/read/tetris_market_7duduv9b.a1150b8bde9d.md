Calculation: normalized(x) = x / max(SMA(abs(x), lookback), floor)
Calculation: score = normalized(ATR(lookback)) + normalized(close - close[1]) + normalized(OBV) + normalized(ROC(close, lookback)) + normalized(ATR(lookback) / max(SMA(ATR(lookback), lookback), floor)) + normalized(EMA(close, shorter EMA lookback) - EMA(close, longer EMA lookback))
Long: score > 0
Short: score < 0