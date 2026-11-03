Calculation: VolatilityPivot stop = recursively updated trailing stop; each bar, delta is either a factor times the EMA of ATR (ATR uses a longer lookback than the EMA) or a fixed price deviation. If the current and previous closes are both below the prior stop, set the stop to the lower of the prior stop and current close + delta; if both are above, set it to the higher of the prior stop and current close - delta; otherwise set it to current close - delta when current close is above the prior stop, or current close + delta when below. Initialize from the close before the calculation history.
Calculation: Upper VolatilityPivot line = stop when close > stop; otherwise empty.
Calculation: Lower VolatilityPivot line = stop when close < stop; otherwise empty.
Long: Upper VolatilityPivot line is present and was empty on the preceding bar.
Short: Lower VolatilityPivot line is present and was empty on the preceding bar.
Exit: Long, Lower VolatilityPivot line is present.
Exit: Short, Upper VolatilityPivot line is present.