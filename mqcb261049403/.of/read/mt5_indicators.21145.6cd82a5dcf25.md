Calculation: Smoothed open, high, low, and close = apply the same selected moving-average method and settings separately to each bar’s open, high, low, and close.
Calculation: Period-candle open = smoothed open from the bar `period - 1` bars ago.
Calculation: Period-candle close = current bar’s smoothed close.
Calculation: Period-candle high = maximum smoothed high over the current bar and preceding `period - 1` bars.
Calculation: Period-candle low = minimum smoothed low over the current bar and preceding `period - 1` bars.
Long: Period-candle open <= period-candle close
Short: Period-candle open > period-candle close