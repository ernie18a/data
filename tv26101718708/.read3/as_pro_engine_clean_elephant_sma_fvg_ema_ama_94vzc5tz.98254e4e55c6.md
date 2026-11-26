Calculation: Elephant bar = high - low > ATR(ATR lookback) * ATR multiplier AND (high - low > 0 ? abs(close - open) / (high - low) : 0) > body-strength threshold
Long: Elephant bar AND close > open
Long: low > high[2]
Long: close crosses above EMA(close, lookback, T1, bar still forming), sampled on chart bars
Short: Elephant bar AND close < open
Short: high < low[2]
Short: close crosses below EMA(close, lookback, T1, bar still forming), sampled on chart bars