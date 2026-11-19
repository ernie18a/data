Calculation: Body ratio = high > low ? abs(close - open) / (high - low) : 0
Long: high - low > ATR(ATR lookback) * ATR multiplier AND Body ratio > body-strength threshold AND close > open
Long: low > high[2]
Long: close crosses above EMA(close, EMA lookback, T1 bar still forming; calculated on T1 bars and sampled on chart bars)
Short: high - low > ATR(ATR lookback) * ATR multiplier AND Body ratio > body-strength threshold AND close < open
Short: high < low[2]
Short: close crosses below EMA(close, EMA lookback, T1 bar still forming; calculated on T1 bars and sampled on chart bars)