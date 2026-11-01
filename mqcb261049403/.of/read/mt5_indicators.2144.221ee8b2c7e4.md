Calculation: Fast and slow rates = one-bar fractional changes of the shorter- and longer-period moving averages of the selected bar price, using the same smoothing method and smoothing parameter; use zero when the previous average is zero.
Calculation: Timeframe trend = on the first chart bar of each selected timeframe at least as high as the chart timeframe, compare the fast rate of its still-forming bar with that of its preceding bar; retain the last non-equal comparison until the next non-equal comparison.
Long: Timeframe trend > 0
Short: Timeframe trend < 0
Long: Fast rate > slow rate AND fast rate != 0 AND slow rate != 0
Short: Fast rate < slow rate AND fast rate != 0 AND slow rate != 0
Long: Fast rate > 0 AND fast rate != previous fast rate
Short: Fast rate < 0 AND fast rate != previous fast rate