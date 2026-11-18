Calculation: Highest high since entry = highest(high from long entry through current bar)
Long: flat AND ((ATH breakout enabled AND high > highest(high, ATH lookback)[1]) OR (T1 breakout enabled AND high > highest(high, T1 lookback) on T1 bars, sampled on the previous chart bar from the T1 bar then forming))
Exit: long, ATR exit enabled AND low <= highest high since entry - ATR(ATR lookback) * ATR multiplier
Exit: long, EMA exit enabled AND close < EMA(close, EMA lookback)