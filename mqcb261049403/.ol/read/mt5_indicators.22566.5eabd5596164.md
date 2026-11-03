Calculation: Smoothed open and close = apply the same configurable moving-average method and lookback separately to each bar’s open and close.
Calculation: Gap-adjusted smoothed open = prior bar’s smoothed close when the absolute difference between the bar’s raw open and close is at most the gap threshold; otherwise, the bar’s smoothed open.
Calculation: Candle direction state = +1 when gap-adjusted smoothed open < smoothed close, −1 when gap-adjusted smoothed open > smoothed close, otherwise the prior bar’s state.
Long: Previous bar’s candle direction state ≤ 0 AND current bar’s candle direction state > 0
Short: Previous bar’s candle direction state ≥ 0 AND current bar’s candle direction state < 0