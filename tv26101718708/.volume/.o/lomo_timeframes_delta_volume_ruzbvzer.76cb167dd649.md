Calculation: Zero-lag EMA = EMA of close plus the difference between close and close from floor((length − 1) / 2) bars earlier, using the same length as the ATR
Calculation: Volatility band width = highest ATR over three times the length, multiplied by a factor
Calculation: Trend state = 1 when close crosses above zero-lag EMA + volatility band width; −1 when close crosses below zero-lag EMA − volatility band width; otherwise retain the prior state, initially 0
Long: On each configured timeframe, trend state = 1, using that timeframe’s current bar (including a still-forming bar)
Short: On each configured timeframe, trend state ≠ 1, using that timeframe’s current bar (including a still-forming bar)