Calculation: Adaptive sub-bar volume = EMA of each chart bar's mean lower-timeframe sub-bar volume, updated only when the chart bar closes; initialize with the first available mean and retain the previous value when no sub-bars are available. Classify sub-bars using the previous chart bar's adaptive volume.
Calculation: Tier imbalance = over a rolling chart-bar window, sum signed volume of the tier divided by sum volume of the tier; use zero if the denominator is at most a small positive tolerance. A lower-timeframe sub-bar's signed volume is its volume if close > open, negative volume if close < open, and zero otherwise. Include available lower-timeframe bars within the current chart bar, including a still-forming bar. A sub-bar is large if its volume >= a larger multiplier of adaptive volume, or small if its volume <= a smaller multiplier; check large first. Before adaptive volume exists, assign sub-bars to neither tier. If no sub-bars are available, assign zero volume and signed volume to both tiers.
Calculation: Smoothed spread = EMA of large-tier imbalance minus small-tier imbalance.
Long: Smoothed spread > positive gate AND previous smoothed spread <= positive gate
Short: Smoothed spread < negative gate AND previous smoothed spread >= negative gate
Long: Smoothed spread >= 0
Short: Smoothed spread < 0
Long: Large-tier imbalance >= 0
Short: Large-tier imbalance < 0
Long: Small-tier imbalance >= 0
Short: Small-tier imbalance < 0
Long: Smoothed spread >= positive gate
Short: Smoothed spread <= negative gate