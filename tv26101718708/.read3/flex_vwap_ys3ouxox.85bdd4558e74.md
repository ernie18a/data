Calculation: VWAP = sum(selected price source × effective volume) / sum(effective volume) since the selected reset; effective volume is volume when positive and 1 otherwise; reset at each selected bar-count interval, confirmed pivot high or low, volume threshold, or T1 boundary, using separate bar-count, pivot-lookback, and volume-threshold parameters; calculated on chart bars using the current bar
Long: trend-color option enabled AND close >= VWAP
Short: trend-color option enabled AND close < VWAP
Long: close crosses above VWAP
Short: close crosses below VWAP