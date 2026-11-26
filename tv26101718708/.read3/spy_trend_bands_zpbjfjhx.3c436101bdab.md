Calculation: Trend = on each completed chart bar, 1 if close > RMA(high, MA length) + ATR(ATR length) * upper multiplier, -1 if close < RMA(high, MA length) - ATR(ATR length) * lower multiplier, otherwise prior Trend; initialize to 0
Long: Trend = 1 AND Trend[1] != 1
Short: Trend = -1 AND Trend[1] != -1