Calculation: T1 short-lookback LWMA = LWMA(typical price, shorter lookback, T1, forming bar), sampled on chart bars
Calculation: chart short-lookback LWMA = LWMA(typical price, shorter lookback, forming chart bar)
Calculation: chart long-lookback LWMA = LWMA(typical price, longer lookback, forming chart bar)
Long: abs(close - close[1]) > retracement threshold × point size AND low[1] < T1 short-lookback LWMA AND close[1] > T1 short-lookback LWMA AND chart short-lookback LWMA > chart long-lookback LWMA AND low[2] < high[1]
Short: abs(close - close[1]) > retracement threshold × point size AND high[1] > T1 short-lookback LWMA AND close[1] < T1 short-lookback LWMA AND chart short-lookback LWMA > chart long-lookback LWMA AND low[1] < high[2]