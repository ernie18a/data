Calculation: T1 high/low = T1 high/low requested on chart bars with lookahead off (prior completed T1 bar except on the final chart bar of each T1 interval, when that interval's completed bar is returned; the still-forming T1 bar in real time)
Calculation: LWADX = (ADX(DMI lookback, ADX smoothing lookback) on chart bars - ADX offset) * ADX scale
Calculation: Target 1 offset = MaxProfit * target 1 fraction
Calculation: Target 2 offset = MaxProfit * target 2 fraction
Calculation: Target 3 offset = MaxProfit * target 3 fraction
Calculation: Long stop = entry price - min(initial stop cap, MaxProfit * initial stop fraction) while the highest chart-bar high since entry is below entry price + Target 1 offset; entry price while it is at least entry price + Target 1 offset and below entry price + Target 2 offset; entry price + Target 1 offset while it is at least entry price + Target 2 offset and below entry price + Target 3 offset; entry price + Target 2 offset once it is at least entry price + Target 3 offset
Long: (close crosses above T1 high OR close crosses above T1 low) AND LWADX > strength threshold AND +DI(DMI lookback) > -DI(DMI lookback) AND LWADX > highest(LWADX on prior bars, strength lookback)
Long: (close crosses above T1 high OR close crosses above T1 low) AND LWADX > strength threshold AND +DI(DMI lookback) > -DI(DMI lookback) AND LWADX > highest(LWADX on prior bars, strength lookback) AND bar time is between session start and session end, inclusive
Exit: long, low <= Long stop OR high >= entry price + MaxProfit OR bar time > session end