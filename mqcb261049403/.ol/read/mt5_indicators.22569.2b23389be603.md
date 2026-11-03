Calculation: Smoothed open and close = apply the same selected smoothing method, lookback, and phase to each bar’s open and close.
Calculation: Gap-adjusted smoothed open = smoothed open, except use the previous bar’s smoothed close when the absolute difference between the bar’s raw open and raw close is less than or equal to the gap threshold.
Calculation: Trend = +1 when gap-adjusted smoothed open < smoothed close; −1 when gap-adjusted smoothed open > smoothed close; otherwise retain the previous trend (initially 0). Calculate on a higher timeframe’s still-forming bar.
Long: previous trend ≤ 0 AND current trend > 0
Short: previous trend ≥ 0 AND current trend < 0