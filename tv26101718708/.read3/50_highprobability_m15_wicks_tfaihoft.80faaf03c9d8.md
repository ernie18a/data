Calculation: Upper wick = high - max(open, close) on T1 bars
Calculation: Lower wick = min(open, close) - low on T1 bars
Long: The previous chart bar's returned T1 value is non-na; on T1 bars, lower wick of the still-forming bar > SMA(lower wick, shared lookback) * shared multiplier AND low < low[1]
Short: The previous chart bar's returned T1 value is non-na; on T1 bars, upper wick of the still-forming bar > SMA(upper wick, shared lookback) * shared multiplier AND high > high[1]