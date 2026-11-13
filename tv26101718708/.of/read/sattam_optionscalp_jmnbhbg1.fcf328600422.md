Calculation: WinHigh = highest high of the last short window of bars on the chart timeframe, including the current bar; WinLow = lowest low of the same window
Calculation: Pos = (hlc3 - WinLow) / (WinHigh - WinLow), or 0 if WinHigh = WinLow
Calculation: Span = max(multiplier * ATR(Wilder, chart timeframe), WinHigh - WinLow)
Long: on a cycle bar (evaluated on bar close, one bar every fixed number of bars, counted from a session, week or fixed phase start) AND Pos > threshold (threshold is above the midpoint, 0.5 < threshold < 1). Reference levels are taken on this bar: Anchor = WinLow, targets = Anchor + ratio * Span for ratio in {inner ratio 1, inner ratio 2, 1}, with 0 < inner ratio 1 < inner ratio 2 < 1
Short: on a cycle bar (same timing as Long) AND Pos <= threshold. Reference levels are taken on this bar: Anchor = WinHigh, targets = Anchor - ratio * Span for ratio in {inner ratio 1, inner ratio 2, 1}
Exit: long, high >= long target level fixed on the entry cycle bar (partial exit at the two inner ratio levels, full exit at ratio 1)
Exit: short, low <= short target level fixed on the entry cycle bar (partial exit at the two inner ratio levels, full exit at ratio 1)