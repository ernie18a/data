Calculation: MAVT line = 100 × normalize(normalize(EMA(close, shorter lookback) − EMA(close, longer lookback), lookback) × normalize(volume / SMA(volume, volume lookback), lookback) / (1 + normalize(ATR(lookback), lookback)), lookback), where normalize(x, lookback) = (x − lowest(x, lookback)) / (highest(x, lookback) − lowest(x, lookback)); when the denominator is zero, normalize = 0.5
Calculation: MAVT histogram = MAVT line − EMA(MAVT line, signal lookback)
Long: MAVT line > 50 OR MAVT histogram >= 0
Short: MAVT line <= 50 OR MAVT histogram < 0