Calculation: Volatility bands = EMA of close ± ATR multiplied by a configurable factor; ratchet the lower band upward while direction is long and the upper band downward while direction is short, resetting the ratcheted band on a direction change.
Calculation: Trend direction = long when close > the prior bar’s upper band; short when close < the prior bar’s lower band; otherwise retain the prior direction. Use the prior completed bar’s bands.
Long: Trend direction changes from short to long.
Short: Trend direction changes from long to short.
Exit: Long, trend direction changes to short.
Exit: Short, trend direction changes to long.