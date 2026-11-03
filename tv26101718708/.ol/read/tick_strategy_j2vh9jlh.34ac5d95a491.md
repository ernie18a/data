Calculation: successive up-ticks = consecutive price increases from one update to the next within the current chart candle; reset to zero on a non-increase or at the start of a new candle
Calculation: successive down-ticks = consecutive price decreases from one update to the next within the current chart candle; reset to zero on a non-decrease or at the start of a new candle
Calculation: tick number = update count from the start of the current chart candle
Long: position is flat AND close > open AND successive up-ticks = entry threshold AND (counting from candle start is disabled OR tick number = entry threshold)
Short: position is flat AND close < open AND successive down-ticks = entry threshold AND (counting from candle start is disabled OR tick number = entry threshold)
Exit: long, successive down-ticks = exit threshold AND (exit on entry candle is enabled OR current candle is later than the entry candle)
Exit: short, successive up-ticks = exit threshold AND (exit on entry candle is enabled OR current candle is later than the entry candle)