Calculation: Consecutive up-tick count = consecutive price updates in the current chart candle whose close is above the preceding update's close; reset to zero otherwise
Calculation: Consecutive down-tick count = consecutive price updates in the current chart candle whose close is below the preceding update's close; reset to zero otherwise
Calculation: Tick index = number of price updates in the current chart candle
Long: flat AND current close > current open AND consecutive up-tick count = entry tick count AND (count-from-candle-start option is disabled OR tick index = entry tick count)
Short: flat AND current close < current open AND consecutive down-tick count = entry tick count AND (count-from-candle-start option is disabled OR tick index = entry tick count)
Exit: long, consecutive down-tick count = exit tick count AND (same-candle exit option is enabled OR current candle is later than the entry candle)
Exit: short, consecutive up-tick count = exit tick count AND (same-candle exit option is enabled OR current candle is later than the entry candle)