Calculation: Smoothed open and close = apply the same configurable moving-average method and lookback separately to each signal-timeframe bar’s open and close.
Calculation: Gap-adjusted smoothed open = previous bar’s smoothed close when the absolute difference between the bar’s raw open and close is at most the gap threshold; otherwise, the current bar’s smoothed open.
Calculation: Candle trend = +1 when gap-adjusted smoothed open < smoothed close, −1 when it > smoothed close, and the previous trend when equal. The signal timeframe is the chart timeframe or a selected higher timeframe; use its still-forming bar.
Long: Previous candle trend ≤ 0 AND current candle trend > 0.
Short: Previous candle trend ≥ 0 AND current candle trend < 0.