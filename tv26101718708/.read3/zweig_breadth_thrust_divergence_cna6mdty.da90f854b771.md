Calculation: BreadthRatio = NYSE advancing issues / (NYSE advancing issues + NYSE declining issues), both on chart bars from the last completed T1 bar
Calculation: BreadthEMA = EMA(BreadthRatio, EMA length)
Calculation: Armed = (BreadthEMA < low threshold AND Armed[1] = false) OR (Armed[1] = true AND BreadthEMA <= high threshold AND BarsSince(BreadthEMA < low threshold)[1] < thrust window)
Calculation: IsPivotHigh(source, lookback) = source[lookback] = Highest(source, 2*lookback+1)
Calculation: IsPivotLow(source, lookback) = source[lookback] = Lowest(source, 2*lookback+1)
Calculation: LastPivotHigh(source, lookback) = source[lookback] if IsPivotHigh(source, lookback), otherwise LastPivotHigh(source, lookback)[1]
Calculation: PrevPivotHigh(source, lookback) = LastPivotHigh(source, lookback)[1] if IsPivotHigh(source, lookback), otherwise PrevPivotHigh(source, lookback)[1]
Calculation: LastPivotLow(source, lookback) = source[lookback] if IsPivotLow(source, lookback), otherwise LastPivotLow(source, lookback)[1]
Calculation: PrevPivotLow(source, lookback) = LastPivotLow(source, lookback)[1] if IsPivotLow(source, lookback), otherwise PrevPivotLow(source, lookback)[1]
Long: BreadthEMA > high threshold AND Armed[1] = true
Long: IsPivotLow(BreadthEMA, pivot lookback) = true AND LastPivotLow(reference index close (last completed T1 bar), pivot lookback) < PrevPivotLow(reference index close (last completed T1 bar), pivot lookback) AND LastPivotLow(BreadthEMA, pivot lookback) > PrevPivotLow(BreadthEMA, pivot lookback)
Short: IsPivotHigh(BreadthEMA, pivot lookback) = true AND LastPivotHigh(reference index close (last completed T1 bar), pivot lookback) > PrevPivotHigh(reference index close (last completed T1 bar), pivot lookback) AND LastPivotHigh(BreadthEMA, pivot lookback) < PrevPivotHigh(BreadthEMA, pivot lookback)