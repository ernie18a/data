Calculation: Normalized ATR = ATR(len) / max(SMA(abs(ATR(len)), len), 1)
Calculation: Normalized delta = (close - previous close) / max(SMA(abs(close - previous close), len), 1)
Calculation: Normalized OBV = OBV / max(SMA(abs(OBV), len), 1), where OBV adds volume when close rises, subtracts volume when close falls, and is unchanged when close is unchanged
Calculation: Normalized momentum = ROC(close, len) / max(SMA(abs(ROC(close, len)), len), 1)
Calculation: Normalized volatility = (ATR(len) / max(SMA(ATR(len), len), 1)) / max(SMA(abs(ATR(len) / max(SMA(ATR(len), len), 1)), len), 1)
Calculation: Normalized trend = (EMA(close, 9) - EMA(close, 21)) / max(SMA(abs(EMA(close, 9) - EMA(close, 21)), len), 1)
Long: Normalized ATR > 1.2 OR normalized delta > 1.2 OR normalized OBV > 1.2 OR normalized momentum > 1.2 OR normalized volatility > 1.2 OR normalized trend > 1.2
Short: Normalized ATR <= 0 OR normalized delta <= 0 OR normalized OBV <= 0 OR normalized momentum <= 0 OR normalized volatility <= 0 OR normalized trend <= 0