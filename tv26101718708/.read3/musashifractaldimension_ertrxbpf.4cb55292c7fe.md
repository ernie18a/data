Calculation: RsiValue = RSI(close, RSI lookback)
Calculation: LowPivotFound = PivotLow(RsiValue, left lookback, right lookback) is not na
Calculation: HighPivotFound = PivotHigh(RsiValue, left lookback, right lookback) is not na
Calculation: PrevLowPivotPrice = ValueWhen(LowPivotFound, low[right lookback], 1)
Calculation: PrevLowPivotRsi = ValueWhen(LowPivotFound, RsiValue[right lookback], 1)
Calculation: PrevHighPivotPrice = ValueWhen(HighPivotFound, high[right lookback], 1)
Calculation: PrevHighPivotRsi = ValueWhen(HighPivotFound, RsiValue[right lookback], 1)
Calculation: BarsSinceLowPivot = BarsSince(LowPivotFound[1])
Calculation: BarsSinceHighPivot = BarsSince(HighPivotFound[1])
Long: LowPivotFound AND low[right lookback] < PrevLowPivotPrice AND RsiValue[right lookback] > PrevLowPivotRsi AND BarsSinceLowPivot >= minimum pivot spacing AND BarsSinceLowPivot <= maximum pivot spacing
Long: LowPivotFound AND low[right lookback] > PrevLowPivotPrice AND RsiValue[right lookback] < PrevLowPivotRsi AND BarsSinceLowPivot >= minimum pivot spacing AND BarsSinceLowPivot <= maximum pivot spacing
Short: HighPivotFound AND high[right lookback] > PrevHighPivotPrice AND RsiValue[right lookback] < PrevHighPivotRsi AND BarsSinceHighPivot >= minimum pivot spacing AND BarsSinceHighPivot <= maximum pivot spacing
Short: HighPivotFound AND high[right lookback] < PrevHighPivotPrice AND RsiValue[right lookback] > PrevHighPivotRsi AND BarsSinceHighPivot >= minimum pivot spacing AND BarsSinceHighPivot <= maximum pivot spacing