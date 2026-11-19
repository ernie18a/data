Calculation: Previous candle vote = 1 if close(T1, last completed bar) > open(T1, last completed bar), -1 if close(T1, last completed bar) < open(T1, last completed bar), otherwise 0
Calculation: Structure vote = 1 if the latest confirmed PivotHigh(high, pivot lookback, pivot lookback) on completed T1 bars > the preceding confirmed PivotHigh and the latest confirmed PivotLow(low, pivot lookback, pivot lookback) on completed T1 bars > the preceding confirmed PivotLow; -1 if both latest pivots are <= their preceding pivots; otherwise 0
Calculation: Opening price vote = 1 if chart close > open(T1, bar still forming), -1 if chart close < open(T1, bar still forming), otherwise 0
Calculation: Combined bias score = previous candle vote + structure vote + opening price vote
Long: Previous candle vote = 1
Short: Previous candle vote = -1
Long: Structure vote = 1
Short: Structure vote = -1
Long: Opening price vote = 1
Short: Opening price vote = -1
Long: Combined bias score >= agreement threshold
Short: Combined bias score <= -agreement threshold