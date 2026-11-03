Calculation: ATR = average true range
Calculation: Upper threshold = lowest low + ATR × multiplier over the lookback
Calculation: Lower threshold = highest high − ATR × multiplier over the lookback
Calculation: Trend state = bullish when close > prior bar’s upper threshold; bearish when close < prior bar’s lower threshold; otherwise retain the prior state
Long: Trend state changes from non-bullish to bullish
Short: Trend state changes from non-bearish to bearish
Exit: long, close < prior bar’s lower threshold
Exit: short, close > prior bar’s upper threshold