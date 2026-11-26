Calculation: HighPivotLevel = latest PivotHigh(high, swing length, swing length) value confirmed before the current bar
Calculation: LowPivotLevel = latest PivotLow(low, swing length, swing length) value confirmed before the current bar
Calculation: UpwardBreak = close > HighPivotLevel AND no earlier bar since HighPivotLevel was confirmed had close > HighPivotLevel
Calculation: DownwardBreak = close < LowPivotLevel AND no earlier bar since LowPivotLevel was confirmed had close < LowPivotLevel
Calculation: StructureDirection = 1 if the latest of UpwardBreak or DownwardBreak, including the current bar, is UpwardBreak; -1 if it is DownwardBreak; 0 if neither has occurred
Calculation: OpposingCandleUp = smallest k from 1 to OB search length with close[k] < open[k] and bar k bars ago at or after the pivot bar of HighPivotLevel
Calculation: OpposingCandleDown = smallest k from 1 to OB search length with close[k] > open[k] and bar k bars ago at or after the pivot bar of LowPivotLevel
Calculation: PriorWindowHigh(W) = highest high of the bars inside session window W (session timezone) in its latest occurrence, defined from the first bar after that occurrence until W's next occurrence begins
Calculation: PriorWindowLow(W) = lowest low of the bars inside session window W (session timezone) in its latest occurrence, defined from the first bar after that occurrence until W's next occurrence begins
Long: UpwardBreak
Short: DownwardBreak
Long: PivotHigh(high, swing length, swing length) > HighPivotLevel
Short: PivotHigh(high, swing length, swing length) < HighPivotLevel
Long: PivotLow(low, swing length, swing length) > LowPivotLevel
Short: PivotLow(low, swing length, swing length) < LowPivotLevel
Long: first bar since LowPivotLevel was confirmed where low < LowPivotLevel AND close > LowPivotLevel, provided no DownwardBreak has occurred since LowPivotLevel was confirmed
Short: first bar since HighPivotLevel was confirmed where high > HighPivotLevel AND close < HighPivotLevel, provided no UpwardBreak has occurred since HighPivotLevel was confirmed
Long: low > high[2] AND low - high[2] >= minimum gap factor * ATR(ATR length A)
Short: high < low[2] AND low[2] - high >= minimum gap factor * ATR(ATR length A)
Long: UpwardBreak AND OpposingCandleUp exists AND close[j] >= low[OpposingCandleUp] for every j from 0 to OpposingCandleUp - 1
Short: DownwardBreak AND OpposingCandleDown exists AND close[j] <= high[OpposingCandleDown] for every j from 0 to OpposingCandleDown - 1
Long: MA(source, MA length 1, MA type 1) > MA(source, MA length 2, MA type 2)
Short: MA(source, MA length 1, MA type 1) < MA(source, MA length 2, MA type 2)
Long: Supertrend(ATR length B, multiplier) direction < 0
Short: Supertrend(ATR length B, multiplier) direction > 0
Long: StructureDirection = 1
Short: StructureDirection = -1
Long: MACD line(close, fast length, slow length) > MACD signal line(close, fast length, slow length, signal length)
Short: MACD line(close, fast length, slow length) <= MACD signal line(close, fast length, slow length, signal length)
Long: MACD histogram(close, fast length, slow length, signal length) >= 0
Short: MACD histogram(close, fast length, slow length, signal length) < 0
Long: first bar of the period where PriorWindowLow(W1) is defined, with low < PriorWindowLow(W1) AND close > PriorWindowLow(W1) AND close < PriorWindowHigh(W1)
Long: first bar of the period where PriorWindowLow(W2) is defined, with low < PriorWindowLow(W2) AND close > PriorWindowLow(W2) AND close < PriorWindowHigh(W2)
Long: first bar of the period where PriorWindowLow(W3) is defined, with low < PriorWindowLow(W3) AND close > PriorWindowLow(W3) AND close < PriorWindowHigh(W3)
Short: first bar of the period where PriorWindowHigh(W1) is defined, with high > PriorWindowHigh(W1) AND close < PriorWindowHigh(W1) AND close > PriorWindowLow(W1)
Short: first bar of the period where PriorWindowHigh(W2) is defined, with high > PriorWindowHigh(W2) AND close < PriorWindowHigh(W2) AND close > PriorWindowLow(W2)
Short: first bar of the period where PriorWindowHigh(W3) is defined, with high > PriorWindowHigh(W3) AND close < PriorWindowHigh(W3) AND close > PriorWindowLow(W3)