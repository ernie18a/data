Calculation: UpBreak = close > most recent non-NA PivotHigh(high, P, P) AND UpBreak was false on every bar from the bar where that PivotHigh became non-NA through the previous bar
Calculation: DnBreak = close < most recent non-NA PivotLow(low, P, P) AND DnBreak was false on every bar from the bar where that PivotLow became non-NA through the previous bar
Calculation: BullFvgFormed = low > high[2] AND close[1] > low[1] + T * ATR(N)[1]
Calculation: BearFvgFormed = high < low[2] AND close[1] < high[1] - T * ATR(N)[1]
Long: UpBreak AND BullFvgFormed
Long: UpBreak[1] AND BullFvgFormed
Long: UpBreak AND exists j >= 1 such that BullFvgFormed[j] AND lowest(min(open, close), j) >= high[j+2]
Short: DnBreak AND BearFvgFormed
Short: DnBreak[1] AND BearFvgFormed
Short: DnBreak AND exists j >= 1 such that BearFvgFormed[j] AND highest(max(open, close), j) <= low[j+2]