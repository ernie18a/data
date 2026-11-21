Calculation: HighPivotLevel(tf) = PivotHigh(high, swing length, swing length) if defined, else HighPivotLevel[1]
Calculation: HighPivotIdx(tf) = bar index - swing length if PivotHigh(high, swing length, swing length) is defined, else HighPivotIdx[1]
Calculation: HighPivotUsed(tf) = close[1] > HighPivotLevel if PivotHigh(high, swing length, swing length) is defined, else (HighPivotUsed[1] OR UpBreak[1])
Calculation: UpBreak(tf) = NOT HighPivotUsed AND close > HighPivotLevel AND close[1] <= HighPivotLevel AND close > open
Calculation: LowPivotLevel(tf) = PivotLow(low, swing length, swing length) if defined, else LowPivotLevel[1]
Calculation: LowPivotIdx(tf) = bar index - swing length if PivotLow(low, swing length, swing length) is defined, else LowPivotIdx[1]
Calculation: LowPivotUsed(tf) = close[1] < LowPivotLevel if PivotLow(low, swing length, swing length) is defined, else (LowPivotUsed[1] OR DownBreak[1])
Calculation: DownBreak(tf) = NOT LowPivotUsed AND close < LowPivotLevel AND close[1] >= LowPivotLevel AND close < open
Calculation: DownCandleIdx(tf) = bar index if close < open, else DownCandleIdx[1]
Calculation: UpCandleIdx(tf) = bar index if close > open, else UpCandleIdx[1]
Calculation: DisplacementGrade(tf) = 3 if D >= grade-3 threshold, 2 if D >= grade-2 threshold, 1 if D >= grade-1 threshold, else 0, where D = 0 if ATR(high, low, close, ATR period) is undefined or 0, else |close - open| / ATR(high, low, close, ATR period)
Calculation: UpOBFormed(tf) = UpBreak AND DownCandleIdx >= HighPivotIdx AND bar index - DownCandleIdx <= OB search window AND DisplacementGrade >= minimum OB grade
Calculation: DownOBFormed(tf) = DownBreak AND UpCandleIdx >= LowPivotIdx AND bar index - UpCandleIdx <= OB search window AND DisplacementGrade >= minimum OB grade
Calculation: UpOBTop(tf) = high at bar DownCandleIdx if UpOBFormed, else UpOBTop[1]
Calculation: UpOBBottom(tf) = low at bar DownCandleIdx if UpOBFormed, else UpOBBottom[1]
Calculation: UpOBFormIdx(tf) = bar index if UpOBFormed, else UpOBFormIdx[1]
Calculation: UpOBValid(tf) = (UpOBFormed OR UpOBValid[1]) AND close >= UpOBBottom
Calculation: DownOBTop(tf) = high at bar UpCandleIdx if DownOBFormed, else DownOBTop[1]
Calculation: DownOBBottom(tf) = low at bar UpCandleIdx if DownOBFormed, else DownOBBottom[1]
Calculation: DownOBFormIdx(tf) = bar index if DownOBFormed, else DownOBFormIdx[1]
Calculation: DownOBValid(tf) = (DownOBFormed OR DownOBValid[1]) AND close <= DownOBTop
Calculation: OverlapPadding(chart) = overlap tolerance factor * ATR(high, low, close, ATR period)
Calculation: UpStack(chart) = 0 if UpOBValid(chart) is false, else 1 + number of H in {T2, T3, T4} such that H is longer than chart AND UpOBValid(H, last completed bar) AND UpOBTop(chart) + OverlapPadding(chart) >= UpOBBottom(H, last completed bar) AND UpOBTop(H, last completed bar) + OverlapPadding(chart) >= UpOBBottom(chart)
Calculation: DownStack(chart) = 0 if DownOBValid(chart) is false, else 1 + number of H in {T2, T3, T4} such that H is longer than chart AND DownOBValid(H, last completed bar) AND DownOBTop(chart) + OverlapPadding(chart) >= DownOBBottom(H, last completed bar) AND DownOBTop(H, last completed bar) + OverlapPadding(chart) >= DownOBBottom(chart)
Long: chart timeframe is T1, T2, T3 or T4 AND UpOBValid(chart) is true
Long: chart timeframe is T1, T2, T3 or T4 AND UpStack(chart) >= 2 AND (UpStack(chart)[1] < 2 OR UpOBFormIdx(chart) != UpOBFormIdx(chart)[1])
Short: chart timeframe is T1, T2, T3 or T4 AND DownOBValid(chart) is true
Short: chart timeframe is T1, T2, T3 or T4 AND DownStack(chart) >= 2 AND (DownStack(chart)[1] < 2 OR DownOBFormIdx(chart) != DownOBFormIdx(chart)[1])