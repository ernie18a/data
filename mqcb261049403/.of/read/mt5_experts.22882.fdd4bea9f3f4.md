Calculation: Smoothed open and close = apply the same configurable smoothing method and parameters to open and close on the configured indicator timeframe (higher or lower than the chart timeframe); use the last completed bar.
Calculation: Lagged smoothed open = smoothed open from the configured candle-period lookback bars earlier.
Long: Smoothed close > lagged smoothed open
Short: Smoothed close <= lagged smoothed open
Exit: Long, smoothed close <= lagged smoothed open
Exit: Short, smoothed close > lagged smoothed open