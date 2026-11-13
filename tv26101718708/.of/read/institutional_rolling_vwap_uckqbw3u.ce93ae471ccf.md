Calculation: RollingVWAP = sum(hlc3 * volume) / sum(volume) over a rolling time-based window ending at the current bar, on chart timeframe
Calculation: RVOL = SMA(volume, shorter lookback) / SMA(volume, longer lookback), on chart timeframe; equals 1 if the longer-lookback average is 0
Calculation: Z = (close - RollingVWAP) / (stdev(close, lookback) / sqrt(max(RVOL, positive floor))), on chart timeframe
Long: (Z > band multiple AND RVOL > high threshold) OR (Z < -band multiple AND RVOL < low threshold), where low threshold < high threshold
Short: (Z < -band multiple AND RVOL > high threshold) OR (Z > band multiple AND RVOL < low threshold), where low threshold < high threshold