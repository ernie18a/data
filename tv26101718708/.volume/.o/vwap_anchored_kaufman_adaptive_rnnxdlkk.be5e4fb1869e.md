Calculation: Efficiency ratio = absolute change in source over its lookback divided by the sum of absolute bar-to-bar source changes over that lookback.
Calculation: Adaptive smoothing factor = square of the efficiency-ratio-weighted interpolation between the fast and slow EMA smoothing factors, where each EMA smoothing factor is 2 divided by its length plus 1.
Calculation: Anchored adaptive VWAP = adaptively smoothed source × volume divided by adaptively smoothed volume; seed both smoothed values from the first bar of each anchor period, then update each from the prior value using the adaptive smoothing factor. Use the current bar's source and volume.
Long: source > anchored adaptive VWAP
Short: source < anchored adaptive VWAP