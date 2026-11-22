Calculation: PivotLowConfirmed = PivotLow(RSI(close, RSI period), left pivot bars, right pivot bars) is not na
Calculation: PivotHighConfirmed = PivotHigh(RSI(close, RSI period), left pivot bars, right pivot bars) is not na
Calculation: InLookbackRange(cond) = minimum range bars <= BarsSince(cond) <= maximum range bars
Long: RSI(close, shorter lookback) >= RSI(close, longer lookback)
Long: PivotLowConfirmed AND low[right pivot bars] < ValueWhen(PivotLowConfirmed, low[right pivot bars], 1) AND RSI(close, RSI period)[right pivot bars] > ValueWhen(PivotLowConfirmed, RSI(close, RSI period)[right pivot bars], 1) AND InLookbackRange(PivotLowConfirmed[1])
Long: PivotLowConfirmed AND low[right pivot bars] > ValueWhen(PivotLowConfirmed, low[right pivot bars], 1) AND RSI(close, RSI period)[right pivot bars] < ValueWhen(PivotLowConfirmed, RSI(close, RSI period)[right pivot bars], 1) AND InLookbackRange(PivotLowConfirmed[1])
Short: RSI(close, shorter lookback) < RSI(close, longer lookback)
Short: PivotHighConfirmed AND high[right pivot bars] > ValueWhen(PivotHighConfirmed, high[right pivot bars], 1) AND RSI(close, RSI period)[right pivot bars] < ValueWhen(PivotHighConfirmed, RSI(close, RSI period)[right pivot bars], 1) AND InLookbackRange(PivotHighConfirmed[1])
Short: PivotHighConfirmed AND high[right pivot bars] < ValueWhen(PivotHighConfirmed, high[right pivot bars], 1) AND RSI(close, RSI period)[right pivot bars] > ValueWhen(PivotHighConfirmed, RSI(close, RSI period)[right pivot bars], 1) AND InLookbackRange(PivotHighConfirmed[1])