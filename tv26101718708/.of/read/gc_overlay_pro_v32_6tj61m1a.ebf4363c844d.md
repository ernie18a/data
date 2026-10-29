Calculation: Volume z-score = (current bar volume − volume moving average over a lookback) ÷ standard deviation of volume over a lookback; use 0 when the standard deviation is 0
Calculation: Upper wick = high − max(open, close)
Calculation: Lower wick = min(open, close) − low
Long: (close > open OR (close = open AND lower wick > upper wick)) AND volume z-score > high-volume threshold
Short: (close < open OR (close = open AND upper wick >= lower wick)) AND volume z-score > high-volume threshold