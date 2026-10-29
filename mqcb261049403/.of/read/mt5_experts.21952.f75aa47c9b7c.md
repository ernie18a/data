Calculation: Smoothed volume-weighted CCI = the configured smoothing of CCI on the configured applied price multiplied by volume, using bars on the indicator timeframe, whether higher or lower than the chart timeframe; use completed bars
Calculation: Smoothed volume = the same configured smoothing of volume on the indicator timeframe, whether higher or lower than the chart timeframe; use completed bars
Long: Current smoothed volume-weighted CCI > HighLevel1 × current smoothed volume AND previous smoothed volume-weighted CCI ≤ HighLevel1 × previous smoothed volume
Long: Current smoothed volume-weighted CCI > HighLevel2 × current smoothed volume AND previous smoothed volume-weighted CCI ≤ HighLevel2 × previous smoothed volume
Short: Current smoothed volume-weighted CCI < LowLevel1 × current smoothed volume AND previous smoothed volume-weighted CCI ≥ LowLevel1 × previous smoothed volume
Short: Current smoothed volume-weighted CCI < LowLevel2 × current smoothed volume AND previous smoothed volume-weighted CCI ≥ LowLevel2 × previous smoothed volume
Exit: Long, current smoothed volume-weighted CCI < LowLevel1 × current smoothed volume
Exit: Short, current smoothed volume-weighted CCI > HighLevel1 × current smoothed volume