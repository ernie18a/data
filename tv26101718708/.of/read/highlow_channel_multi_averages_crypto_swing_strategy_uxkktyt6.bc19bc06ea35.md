Calculation: High average = arithmetic mean of the SMA, EMA, WMA, ALMA, Wilder’s moving average, endpoint linear regression, and VWMA of high, all using the same lookback
Calculation: Low average = arithmetic mean of the SMA, EMA, WMA, ALMA, Wilder’s moving average, endpoint linear regression, and VWMA of low, all using the same lookback
Long: close > high average
Short: close < low average
Exit: Long, high >= entry price + close × long take-profit fraction OR low <= entry price - close × long stop-loss fraction OR low < low average AND previous low >= previous low average
Exit: Short, low <= entry price - close × short take-profit fraction OR high >= entry price + close × short stop-loss fraction OR high > high average AND previous high <= previous high average