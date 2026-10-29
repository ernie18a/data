Calculation: ComboMA = average of ALMA(close, lookback) and zero-lag moving average, where zero-lag moving average = EMA(2 × EMA(close, lookback) − EMA(EMA(close, lookback), lookback), lookback); both use the same lookback
Calculation: Volume RSI = RSI(volume, lookback) / 50; its lookback is shorter than the close RSI lookback
Long: ComboMA increased on each of the last N bars AND close > ComboMA AND Volume RSI > threshold AND RSI(close, longer lookback) > threshold
Short: ComboMA decreased on each of the last N bars AND close < ComboMA AND Volume RSI > threshold AND RSI(close, longer lookback) < threshold
Exit: long, close < ComboMA − ATR × trail multiplier OR ComboMA decreased from the prior bar OR low ≤ entry price − ATR × stop multiplier OR high ≥ entry price + ATR × take-profit multiplier
Exit: short, close > ComboMA + ATR × trail multiplier OR ComboMA increased from the prior bar OR high ≥ entry price + ATR × stop multiplier OR low ≤ entry price − ATR × take-profit multiplier