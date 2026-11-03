Calculation: DeMark price = if close < open, (low + close) / 2; if close > open, (high + close) / 2; otherwise close; if the result is zero, use close.
Calculation: XMA = the selected smoothing algorithm applied to DeMark price, on the configured indicator timeframe (which may be higher or lower than the chart timeframe), using completed bars.
Long: XMA[current] > XMA[previous] AND XMA[previous] <= XMA[bar before previous]
Short: XMA[current] < XMA[previous] AND XMA[previous] >= XMA[bar before previous]
Exit: long, XMA[current] < XMA[previous]
Exit: short, XMA[current] > XMA[previous]