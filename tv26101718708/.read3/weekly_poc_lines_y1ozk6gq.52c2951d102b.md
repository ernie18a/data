Calculation: T1 POC = On chart bars, accumulate T2 intrabars and chart-bar OHLCV in each still-forming T1 period; split each bar’s volume equally among an adjustable number of equal-width rows spanning the period’s low to high; select the center of the highest-volume row as the POC and track bull volume (close >= open) and bear volume (close < open) in that row.
Long: For each plotted T1 POC, chart close > T1 POC.
Short: For each plotted T1 POC, chart close <= T1 POC.
Long: For each plotted T1 POC, bull volume in its highest-volume row >= bear volume in that row.
Short: For each plotted T1 POC, bull volume in its highest-volume row < bear volume in that row.