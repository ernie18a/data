Calculation: direction = if close > moving average(high, lookback) then 1 else if close < moving average(low, lookback) then -1 else direction[1]
Long: direction > 0
Short: direction < 0