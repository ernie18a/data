Calculation: Upper level = highest(open(T1, still-forming bar, sampled on chart bars)[1], lookback on chart bars)
Calculation: Lower level = lowest(open(T1, still-forming bar, sampled on chart bars)[1], lookback on chart bars)
Long: close[2] > Upper level AND Upper level[2] > Upper level[1] AND close > Upper level
Short: close[2] < Lower level AND Lower level[2] > Lower level[1] AND close < Lower level
Exit: long, high >= entry price + profit offset OR low <= entry price - loss offset
Exit: short, low <= entry price - profit offset OR high >= entry price + loss offset