Calculation: Active swing high = most recent confirmed PivotHigh(high, swing lookback, swing lookback), replaced at each confirmation and consumed when close exceeds it
Calculation: Active swing low = most recent confirmed PivotLow(low, swing lookback, swing lookback), replaced at each confirmation and consumed when close falls below it
Calculation: Swing trend = bearish after a bearish swing break, bullish after a bullish swing break, initially neutral
Calculation: Active internal high = most recent confirmed PivotHigh(high, internal lookback, internal lookback), replaced at each confirmation and consumed when close exceeds it
Calculation: Active internal low = most recent confirmed PivotLow(low, internal lookback, internal lookback), replaced at each confirmation and consumed when close falls below it
Long: close > active swing high AND swing trend is bearish
Long: close > active swing high AND swing trend is not bearish
Long: close > active swing high AND swing trend is bearish AND volume > SMA(volume, volume lookback) * volume spike multiplier
Short: close < active swing low AND swing trend is bullish
Short: close < active swing low AND swing trend is not bullish
Short: close < active swing low AND swing trend is bullish AND volume > SMA(volume, volume lookback) * volume spike multiplier
Long: internal structure enabled AND close > active internal high
Short: internal structure enabled AND close < active internal low
Long: FVG detection enabled AND low > high[2] AND (minimum gap parameter is zero OR low - high[2] >= ATR(ATR lookback) * minimum gap parameter)
Short: FVG detection enabled AND high < low[2] AND (minimum gap parameter is zero OR low[2] - high >= ATR(ATR lookback) * minimum gap parameter)