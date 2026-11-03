Calculation: relative volume = current bar volume / simple moving average of volume over a lookback
Calculation: premarket high = highest high during the current day's premarket session
Calculation: active stop = greater of hard stop and trailing stop; hard stop = entry bar close minus a fixed offset; trailing stop = highest high since entry minus ATR times a multiplier
Long: flat AND more than five bars have elapsed since the last exit AND relative volume is at least a threshold AND close > VWAP AND close > EMA AND close > premarket high AND (previous close < previous open OR previous close < previous EMA) AND close > previous high AND close is within a price range
Exit: long, close < active stop OR low < hard stop OR close crosses below VWAP