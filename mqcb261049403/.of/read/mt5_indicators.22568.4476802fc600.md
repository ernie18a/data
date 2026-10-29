Calculation: Smoothed open and close = Apply the same configurable price-smoothing method and lookback to each bar’s open and close, respectively.
Calculation: Gap-adjusted smoothed open = Previous bar’s smoothed close when the absolute difference between the current raw open and close is at most the configurable gap threshold; otherwise, the current smoothed open.
Calculation: Candle direction = +1 when gap-adjusted smoothed open < smoothed close, −1 when gap-adjusted smoothed open > smoothed close, and the previous candle direction when they are equal.
Long: Previous candle direction ≤ 0 AND current candle direction = +1
Short: Previous candle direction ≥ 0 AND current candle direction = −1
Long: On any of the ten configured chart timeframes, the latest bar’s candle direction = +1 (use the bar still forming; each timeframe is equal to or higher than the chart timeframe)
Short: On any of the ten configured chart timeframes, the latest bar’s candle direction = −1 (use the bar still forming; each timeframe is equal to or higher than the chart timeframe)