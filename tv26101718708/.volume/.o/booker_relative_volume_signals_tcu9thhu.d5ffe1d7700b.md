Calculation: RVOL = current bar volume divided by the average volume over a lookback period
Calculation: Premarket high = highest high of the current day's premarket bars
Calculation: Hard stop = entry bar close minus a fixed price offset
Calculation: Trailing stop = highest high since entry minus ATR multiplied by a stop multiplier
Calculation: Active stop = the higher of the hard stop and trailing stop
Long: flat AND cooldown elapsed since prior exit AND RVOL >= minimum threshold AND close > VWAP AND close > EMA AND close > current day's premarket high AND (previous bar close < previous bar open OR previous bar close < previous bar EMA) AND close > previous bar high AND close within the permitted price range
Exit: long, close < active stop OR low < hard stop OR close crosses below VWAP