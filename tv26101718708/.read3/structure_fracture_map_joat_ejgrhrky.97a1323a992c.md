Calculation: Last pivot high = last confirmed PivotHigh(high, pivot lookback, pivot lookback), or 0 before the first confirmed pivot high
Calculation: Last pivot low = last confirmed PivotLow(low, pivot lookback, pivot lookback), or 0 before the first confirmed pivot low
Calculation: Upward break = close crosses above Last pivot high
Calculation: Downward break = close crosses below Last pivot low
Calculation: Structure direction = 1 if Upward break, -1 if Downward break, otherwise Structure direction[1], with 0 on the first bar
Long: Upward break
Short: Downward break
Long: low > high[2]
Short: high < low[2]
Long: Last pivot high > Last pivot high[1]
Long: Last pivot low > Last pivot low[1]
Short: PivotHigh(high, pivot lookback, pivot lookback) is not na AND Last pivot high <= Last pivot high[1]
Short: PivotLow(low, pivot lookback, pivot lookback) is not na AND Last pivot low <= Last pivot low[1]
Long: Structure direction[1] = 1
Short: Structure direction[1] = -1
Long: Structure direction = 1
Short: Structure direction = -1
Long: close > EMA(close, trend length)
Short: close <= EMA(close, trend length)