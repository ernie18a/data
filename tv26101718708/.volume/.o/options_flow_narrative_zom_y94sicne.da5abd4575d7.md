Calculation: Buy volume = volume when close > open; otherwise volume / 2
Calculation: Sell volume = volume when close < open; otherwise volume / 2
Calculation: Delta ratio = EMA(buy volume, bias lookback) / EMA(sell volume, bias lookback)
Calculation: Put-wall high = VWAP − standard deviation of close over gamma lookback × gamma width
Calculation: Call-wall low = VWAP + standard deviation of close over gamma lookback × gamma width
Long: Delta ratio > 1 AND VIX close < EMA(VIX close) AND close > put-wall high AND prior close <= prior put-wall high
Short: Delta ratio < 1 AND VIX close > EMA(VIX close) AND close < call-wall low AND prior close >= prior call-wall low
Exit: Long, Delta ratio > 1 AND VIX close < EMA(VIX close) AND close > call-wall low AND prior close <= prior call-wall low AND NOT (close > put-wall high AND prior close <= prior put-wall high)
Exit: Short, Delta ratio < 1 AND VIX close > EMA(VIX close) AND close < put-wall high AND prior close >= prior put-wall high AND NOT (close < call-wall low AND prior close >= prior call-wall low)