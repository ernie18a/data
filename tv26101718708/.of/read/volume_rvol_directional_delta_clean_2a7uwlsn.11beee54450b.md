Calculation: Relative volume = current chart-bar volume divided by a positive volume baseline. If time-of-day mode is enabled on an intraday chart, collect up to a target number of the most recent prior chart bars with the same opening hour and minute, within a maximum search distance; use their median or mean volume if at least a minimum number of samples is available. Otherwise, use the median or mean volume over a rolling lookback of prior completed chart bars.
Calculation: Signed volume = volume multiplied by 1 if close > open, or by -1 if close < open; if close = open, multiply by 1 if close > the previous bar's close, by -1 if close < the previous bar's close, and by 0 otherwise.
Calculation: Directional delta = sum of signed volume for all available lower-timeframe bars within the current chart bar, including the lower-timeframe bar still forming; if no lower-timeframe bars are available, use the current chart bar's signed volume.
Calculation: Cumulative directional delta = sum of directional delta over a chart-bar lookback, excluding chart bars without lower-timeframe data; undefined if no chart bars in the lookback have lower-timeframe data.
Long: Directional delta > 0
Short: Directional delta < 0
Long: Cumulative directional delta > 0
Short: Cumulative directional delta < 0
Long: Relative volume >= extreme-volume threshold AND lower-timeframe data is available AND directional delta > 0
Short: Relative volume >= extreme-volume threshold AND lower-timeframe data is available AND directional delta < 0
Long: Relative volume >= extreme-volume threshold AND close > open
Short: Relative volume >= extreme-volume threshold AND close < open