Calculation: UpperLevel = highest value, over the upper lookback of chart bars ending with the previous chart bar, of the open of the reference-timeframe bar containing each of those chart bars (that open is known at the start of the bar and the bar need not be completed)
Calculation: LowerLevel = lowest value, over the lower lookback of chart bars ending with the previous chart bar, of the open of the reference-timeframe bar containing each of those chart bars (that open is known at the start of the bar and the bar need not be completed)
Long: close > UpperLevel AND UpperLevel[2] > UpperLevel[1]
Short: close < LowerLevel AND LowerLevel[2] > LowerLevel[1]
Calculation: HighestHighSinceEntry = highest high of chart bars from the entry bar through the current bar
Calculation: LowestLowSinceEntry = lowest low of chart bars from the entry bar through the current bar
Exit: long, high >= entry price + profit distance OR low <= entry price - loss distance OR low <= HighestHighSinceEntry - trail distance
Exit: short, low <= entry price - profit distance OR high >= entry price + loss distance OR high >= LowestLowSinceEntry + trail distance