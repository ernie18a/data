Calculation: Trail offset = ATR multiplier × ATR(ATR lookback)
Calculation: In session = time(chart timeframe, session) != 0
Long: On chart bars, close crosses above high(T1, bar still forming)
Short: On chart bars, close crosses below low(T1, bar still forming)
Exit: long, low <= stop price OR (high >= entry price + trail activation distance AND low <= highest(high since activation) - trail offset) OR NOT In session
Exit: short, high >= stop price OR (low <= entry price - trail activation distance AND high >= lowest(low since activation) + trail offset) OR NOT In session