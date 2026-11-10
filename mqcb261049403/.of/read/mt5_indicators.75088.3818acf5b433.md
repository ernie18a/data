Calculation: Multitimeframe score = sum, across the configured chart, higher, and lower timeframes, of +1 when that timeframe's close is above its moving average and -1 otherwise; use each timeframe's bar still forming.
Calculation: Recent high and low = highest high and lowest low over a window of completed chart bars; previous high and low = highest high and lowest low over the immediately preceding, equally long window.
Calculation: Lower band = chart-timeframe moving average multiplied by one minus a deviation percentage; the inner lower band has the smallest deviation.
Calculation: Deviation = absolute difference between chart close and its moving average, divided by that moving average.
Long: Chart close > chart moving average
Short: Chart close <= chart moving average
Long: Recent high > previous high AND recent low > previous low
Short: Recent high <= previous high AND recent low <= previous low
Long: Close > moving average on any configured chart, higher, or lower timeframe, using its bar still forming
Short: Close <= moving average on any configured chart, higher, or lower timeframe, using its bar still forming
Long: Multitimeframe score > 0
Short: Multitimeframe score < 0
Long: Multitimeframe score >= strong-bull threshold AND chart close <= inner lower band
Long: Multitimeframe score = 0 AND ADX <= weak-trend threshold AND chart close < chart moving average AND deviation >= extreme-deviation threshold
Short: Multitimeframe score = 0 AND ADX <= weak-trend threshold AND chart close > chart moving average AND deviation >= extreme-deviation threshold
Exit: long, multitimeframe score >= strong-bull threshold AND chart close > chart moving average AND deviation >= extreme-deviation threshold