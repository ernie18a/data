Calculation: RSI = RSI(close, RSI length)
Calculation: PivotLowFound = PivotLow(RSI, left lookback, right lookback) is not NA
Calculation: PivotHighFound = PivotHigh(RSI, left lookback, right lookback) is not NA
Calculation: WithinPivotSpacing(cond) = min pivot distance <= BarsSince(cond[1]) <= max pivot distance
Calculation: PrevPivotLowRSI = ValueWhen(PivotLowFound, RSI[right lookback], 1)
Calculation: PrevPivotLowPrice = ValueWhen(PivotLowFound, low[right lookback], 1)
Calculation: PrevPivotHighRSI = ValueWhen(PivotHighFound, RSI[right lookback], 1)
Calculation: PrevPivotHighPrice = ValueWhen(PivotHighFound, high[right lookback], 1)
Long: PivotLowFound AND RSI[right lookback] > PrevPivotLowRSI AND low[right lookback] < PrevPivotLowPrice AND WithinPivotSpacing(PivotLowFound)
Long: PivotLowFound AND RSI[right lookback] < PrevPivotLowRSI AND low[right lookback] > PrevPivotLowPrice AND WithinPivotSpacing(PivotLowFound)
Short: PivotHighFound AND RSI[right lookback] < PrevPivotHighRSI AND high[right lookback] > PrevPivotHighPrice AND WithinPivotSpacing(PivotHighFound)
Short: PivotHighFound AND RSI[right lookback] > PrevPivotHighRSI AND high[right lookback] < PrevPivotHighPrice AND WithinPivotSpacing(PivotHighFound)