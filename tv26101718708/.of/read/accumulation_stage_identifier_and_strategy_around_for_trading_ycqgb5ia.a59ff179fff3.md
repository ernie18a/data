Calculation: Rising(series, lookback) = current value is greater than every value in the preceding lookback bars
Calculation: Falling(series, lookback) = current value is less than every value in the preceding lookback bars
Long: close > long-term SMA AND shorter-term SMA > longer-term SMA (both shorter than the long-term SMA) AND Rising(high, lookback) AND Rising(long-term SMA, lookback) AND MACD line of Price Volume Trend > its signal line
Short: MACD line of Price Volume Trend < its signal line AND Falling(low, lookback) AND close < prior close AND close < open