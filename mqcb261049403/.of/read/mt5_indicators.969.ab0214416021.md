Calculation: Range per volume = (high - low) / volume; use 1 when the result is 0.
Calculation: Swing = (high - low + abs(open - close)) / (2 * Range per volume).
Calculation: Down-bar series = Swing + max(open - close, 0) / Range per volume.
Calculation: Up-bar series = Swing + max(close - open, 0) / Range per volume.
Calculation: Smoothed down-bar series and smoothed up-bar series = apply the same selected smoothing method and parameters to the respective series; the selectable methods are SMA, EMA, SMMA, LWMA, JJMA, JurX, parabolic moving average, T3, VIDYA, and Kaufman adaptive moving average.
Long: Smoothed down-bar series < smoothed up-bar series.
Short: Smoothed down-bar series > smoothed up-bar series.