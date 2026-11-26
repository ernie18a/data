Calculation: direction = if MA(close, smoothing lookback) - MA(close, smoothing lookback)[1] > filter threshold in points then 1, else if MA(close, smoothing lookback)[1] - MA(close, smoothing lookback) > filter threshold in points then -1, else direction[1]
Long: direction = 1
Short: direction = -1
Calculation: T1 direction = the same direction calculation using MA(close, smoothing lookback, T1, bar still forming), evaluated on T1 bars and carried to chart bars
Long: T1 direction = 1
Short: T1 direction = -1