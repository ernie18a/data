Calculation: Relative Z-score = EMA((r − SMA(r, z-score lookback)) / STDEV(r, z-score lookback), final EMA lookback), where r = EMA(asset T1 close / benchmark T1 close, ratio EMA lookback); evaluate on chart bars using the current T1 close, and return 0 when standard deviation is zero.
Calculation: Currency benchmark = 1 + currency debasement adjustment / 100.
Calculation: Up-votes = count of the currency, equity-index, and gold relative Z-scores at or above the overextension threshold.
Calculation: Down-votes = count of the currency, equity-index, and gold relative Z-scores at or below the undervaluation threshold.
Long: the primary-benchmark relative Z-score crosses above the negative extreme threshold; the bullish signal remains current through the freshness lookback in chart bars unless replaced by a bearish cross.
Short: the primary-benchmark relative Z-score crosses below the positive extreme threshold; the bearish signal remains current through the freshness lookback in chart bars unless replaced by a bullish cross.
Long: Up-votes = 3 OR (Up-votes = 2 AND Down-votes < 3) OR (Up-votes = 1 AND Down-votes < 2).
Short: (Down-votes = 3 AND Up-votes < 3) OR (Down-votes = 2 AND Up-votes < 2) OR (Down-votes = 1 AND Up-votes = 0).
Long: the universe is homogeneous AND this asset has a fresh bullish primary-benchmark cross AND Down-votes ≥ 2 AND another asset has a fresh bearish primary-benchmark cross AND Up-votes ≥ 2.
Short: the universe is homogeneous AND this asset has a fresh bearish primary-benchmark cross AND Up-votes ≥ 2 AND another asset has a fresh bullish primary-benchmark cross AND Down-votes ≥ 2.