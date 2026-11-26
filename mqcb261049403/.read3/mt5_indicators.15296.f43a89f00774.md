Calculation: chart histogram = Smoothing(applied price − Smoothing(applied price, method 1, lookback 1, phase 1), method 2, lookback 2, phase 2)
Calculation: T1 histogram = Smoothing(applied price − Smoothing(applied price, method 1 T1, lookback 1 T1, phase 1 T1, T1 bar still forming), method 2 T1, lookback 2 T1, phase 2 T1, T1 bar still forming); computed on T1 bars and sampled on chart bars
Long: chart histogram > 0 AND chart histogram ≠ chart histogram[1]
Long: T1 histogram > 0 AND T1 histogram ≠ T1 histogram[1]
Short: chart histogram < 0 AND chart histogram ≠ chart histogram[1]
Short: T1 histogram < 0 AND T1 histogram ≠ T1 histogram[1]