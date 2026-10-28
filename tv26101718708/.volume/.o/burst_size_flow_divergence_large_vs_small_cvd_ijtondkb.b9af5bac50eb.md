Calculation: Intrabar volume reference = EMA of mean lower-timeframe sub-bar volume per chart bar, updated only on completed chart bars; classify each sub-bar using the prior completed reference: large if volume ≥ a large-volume multiple of the reference, small if volume ≤ a small-volume multiple; otherwise medium.
Calculation: Signed sub-bar volume = volume if close > open, −volume if close < open, and 0 if close = open.
Calculation: Large-tier imbalance = rolling sum of signed volume for large sub-bars divided by rolling sum of their volume; Small-tier imbalance = the same calculation for small sub-bars, using the same lookback.
Calculation: Smoothed spread = EMA of (Large-tier imbalance − Small-tier imbalance), using a shorter smoothing length than the imbalance lookback.
Long: Smoothed spread crosses above a positive divergence threshold.
Short: Smoothed spread crosses below the negative of the positive divergence threshold.