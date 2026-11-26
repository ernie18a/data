Calculation: SweepPriceOverlap(price) = any previously stored sweep price differs from price by less than ATR(lookback) × distance parameter
Long: PivotLow(low, lookback, lookback) is confirmed AND NOT SweepPriceOverlap(PivotLow(low, lookback, lookback))
Short: PivotHigh(high, lookback, lookback) is confirmed AND NOT SweepPriceOverlap(PivotHigh(high, lookback, lookback))