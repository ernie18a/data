Calculation: Main moving average = configured EMA, SMA, WMA, or VWMA of close, or VWAP of hlc3, using the configured length on the chart bars
Calculation: Slope = current linear-regression value of close over the configured lookback minus its value one bar earlier, using bars of the configured slope timeframe; use the bar still forming
Long: While flat, close crosses above the main moving average AND (slope filter enabled AND slope > 0 OR slope filter disabled AND (daily filter disabled OR previous completed daily close > open)) AND not past the enabled Friday cutoff; place a buy stop at the main moving average plus the configured offset, keep it pending until filled, and cancel it if close crosses below the main moving average first
Short: While flat, close crosses below the main moving average AND (slope filter enabled AND slope < 0 OR slope filter disabled AND (daily filter disabled OR previous completed daily close < open)) AND not past the enabled Friday cutoff; place a sell stop at the main moving average minus the configured offset, keep it pending until filled, and cancel it if close crosses above the main moving average first
Exit: Long, low <= the low of the candle that crossed above the main moving average (when the initial stop is enabled)
Exit: Short, high >= the high of the candle that crossed below the main moving average (when the initial stop is enabled)
Exit: Long, high >= entry price plus any of the six configured profit target distances
Exit: Short, low <= entry price minus any of the six configured profit target distances
Exit: Long, high >= entry price plus the configured activation distance AND thereafter close crosses below the main moving average (when MA cross-back is enabled)
Exit: Short, low <= entry price minus the configured activation distance AND thereafter close crosses above the main moving average (when MA cross-back is enabled)
Exit: Long, datetime is Friday at or after the configured weekly cutoff (when weekly close is enabled)
Exit: Short, datetime is Friday at or after the configured weekly cutoff (when weekly close is enabled)