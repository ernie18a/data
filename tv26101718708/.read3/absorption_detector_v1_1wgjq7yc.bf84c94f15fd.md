Calculation: volume-range ratio = volume / max(high - low, minimum tick)
Calculation: smoothed normalized absorption score = SMA((volume-range ratio - SMA(volume-range ratio, normalization lookback)) / max(STDEV(volume-range ratio, normalization lookback), standard-deviation floor), smoothing length)
Calculation: close delta = 2 * (close - low) / max(high - low, minimum tick) - 1
Long: smoothed normalized absorption score > absorption threshold AND close delta > delta threshold
Short: smoothed normalized absorption score > absorption threshold AND close delta < -delta threshold