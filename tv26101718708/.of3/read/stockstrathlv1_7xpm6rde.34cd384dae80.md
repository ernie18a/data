Calculation: rolling high = highest(open(T1, still-forming bar)[1 chart bar ago], lookback) on chart bars
Calculation: rolling low = lowest(open(T1, still-forming bar)[1 chart bar ago], lookback) on chart bars
Long: close > rolling high AND rolling high[2 chart bars ago] > rolling high[1 chart bar ago]
Short: close < rolling low AND rolling low[2 chart bars ago] > rolling low[1 chart bar ago]
Exit: long, high >= entry price + profit-distance parameter in ticks OR low <= entry price - loss-distance parameter in ticks
Exit: short, low <= entry price - profit-distance parameter in ticks OR high >= entry price + loss-distance parameter in ticks