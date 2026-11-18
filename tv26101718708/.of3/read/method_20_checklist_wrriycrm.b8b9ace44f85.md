Calculation: Real body = ABS(close - open)
Calculation: Candle range = high - low
Calculation: Lower shadow = MIN(open, close) - low
Calculation: Upper shadow = high - MAX(open, close)
Long: close > open
Short: close < open
Long: Lower shadow >= Real body * lower-shadow ratio AND Upper shadow <= Real body * upper-shadow ratio
Long: Real body >= Candle range * marubozu ratio AND close > open
Long: close > open AND volume > volume[1]
Short: close < open AND volume > volume[1]
Long: CCI(close, CCI lookback) <= -CCI threshold
Short: CCI(close, CCI lookback) >= CCI threshold
Long: low > high[1]
Short: high < low[1]