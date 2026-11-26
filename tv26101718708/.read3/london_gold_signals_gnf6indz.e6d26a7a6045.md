Calculation: AsiaBreakDirection = 1 if close > maximum(high over the previous Asia session), -1 if close < minimum(low over the previous Asia session), otherwise 0
Calculation: VWAPSide = 1 if close > VWAP(hlc3), otherwise -1
Calculation: NewsRetestDirection = -1 if a news-candle high exists and abs(close - news-candle high) <= ATR(lookback parameter) * distance-threshold parameter; otherwise 1 if a news-candle low exists and abs(close - news-candle low) <= ATR(lookback parameter) * distance-threshold parameter; otherwise 0
Calculation: BiasDirection = 1 if the count of positive values among AsiaBreakDirection, VWAPSide, and NewsRetestDirection exceeds the count of negative values; -1 if the count of negative values exceeds the count of positive values; otherwise 0
Long: AsiaBreakDirection = 1
Short: AsiaBreakDirection = -1
Long: VWAPSide = 1
Short: VWAPSide = -1
Long: NewsRetestDirection = 1
Short: NewsRetestDirection = -1
Long: BiasDirection = 1
Short: BiasDirection = -1