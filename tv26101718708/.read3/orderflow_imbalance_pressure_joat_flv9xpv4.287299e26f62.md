Calculation: Estimated volume delta = if high > low then volume * ((close - low) - (high - close)) / (high - low) else 0
Calculation: Volume delta ratio = if volume > 0 then estimated volume delta / volume else 0
Calculation: Cumulative delta = cumulative sum of estimated volume delta from the configured reset event
Calculation: Pivot side length = int(max(pivot minimum parameter, divergence lookback parameter / pivot divisor parameter))
Calculation: Smoothed delta Z-score = EMA(if STDEV(estimated volume delta, normalization lookback) > 0 then (estimated volume delta - SMA(estimated volume delta, normalization lookback)) / STDEV(estimated volume delta, normalization lookback) else 0, delta smoothing length)
Long: Estimated volume delta >= 0
Short: Estimated volume delta < 0
Long: Volume delta ratio > bias threshold
Short: Volume delta ratio < negative bias threshold
Long: Volume delta ratio > imbalance threshold
Short: Volume delta ratio < negative imbalance threshold
Long: Cumulative delta >= 0
Short: Cumulative delta < 0
Long: Smoothed delta Z-score >= 0
Short: Smoothed delta Z-score < 0
Long: On a confirmed chart bar, PivotLow(low, pivot side length, pivot side length) is confirmed after a prior confirmed pivot low, current pivot low < prior pivot low AND cumulative delta[pivot side length] > cumulative delta at the prior confirmed pivot low
Short: On a confirmed chart bar, PivotHigh(high, pivot side length, pivot side length) is confirmed after a prior confirmed pivot high, current pivot high > prior pivot high AND cumulative delta[pivot side length] < cumulative delta at the prior confirmed pivot high
Long: Smoothed delta Z-score crosses above the delta surge threshold
Short: Smoothed delta Z-score crosses below negative the delta surge threshold