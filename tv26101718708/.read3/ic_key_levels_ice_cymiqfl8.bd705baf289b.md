Calculation: upper wick = high - max(open, close)
Calculation: lower wick = min(open, close) - low
Long: low < low[1] AND high > high[1] AND close > high[1] AND (wick filter disabled OR lower wick > upper wick)
Short: high > high[1] AND low < low[1] AND close < low[1] AND (wick filter disabled OR upper wick > lower wick)