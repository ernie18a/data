Calculation: Selected price = the configured applied price derived from the chart bar’s open, high, low, and close
Calculation: First smooth = the selected price smoothed with the configured method and lookback
Calculation: Second smooth = the first smooth smoothed again with the same method and lookback
Calculation: Average smooth = (first smooth + second smooth) / 2
Calculation: Deviation = (chart-bar close - average smooth) / 4
Long: Deviation > 0
Short: Deviation < 0