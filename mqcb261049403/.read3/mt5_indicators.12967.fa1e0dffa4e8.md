Calculation: range = Highest(high, lookback) - Lowest(low, lookback)
Calculation: trend = -1 if close < Lowest(low, lookback) + range * shift percentage and previous trend != -1; otherwise +1 if close > Highest(high, lookback) - range * shift percentage and previous trend != +1; otherwise previous trend; initially 0
Long: trend = +1
Short: trend = -1