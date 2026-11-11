Calculation: Latest gap = the most recent chart-timeframe or selected higher- or lower-timeframe bar where the preceding bar's low is above the high three bars back, or its high is below the low three bars back. For another timeframe, use its last completed bar; for a lower timeframe, use the last completed lower-timeframe bar within the chart bar. Record the gap direction and its boundaries: for bullish gaps, top = preceding bar's low and bottom = high three bars back; for bearish gaps, top = low three bars back and bottom = preceding bar's high.
Calculation: Gap-period low and high = the lowest low and highest high, respectively, from the bar on which the latest gap is detected through the current bar on that gap's timeframe; reset both when a new gap is detected.
Long: Chart-timeframe low one bar ago > high three bars ago
Short: Chart-timeframe high one bar ago < low three bars ago
Long: Latest gap direction = bullish AND gap-period low >= gap top
Long: Latest gap direction = bullish AND gap-period low < gap top
Short: Latest gap direction = bearish AND gap-period high <= gap bottom
Short: Latest gap direction = bearish AND gap-period high > gap bottom