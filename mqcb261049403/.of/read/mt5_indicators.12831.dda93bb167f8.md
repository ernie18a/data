Calculation: Smoothed oscillator = smooth D − MA(D, floor(sqrt(N))) with a selectable moving-average method and independent lookback, where D = 2 × MA(price, floor(N/2)) − MA(price, N); the three MAs use the same selectable method and parameters other than lookback, and price is a selectable OHLC-derived price.
Calculation: Slope = smoothed oscillator on the current bar − smoothed oscillator on the previous bar, calculated on either the chart timeframe or the higher timeframe using its still-forming bar.
Long: Chart-timeframe slope > 0 AND previous chart-timeframe slope ≤ 0
Short: Chart-timeframe slope < 0 AND previous chart-timeframe slope ≥ 0
Long: The most recent higher-timeframe slope crossing from ≤ 0 to > 0 is more recent than the most recent crossing from ≥ 0 to < 0
Short: The most recent higher-timeframe slope crossing from ≥ 0 to < 0 is more recent than the most recent crossing from ≤ 0 to > 0