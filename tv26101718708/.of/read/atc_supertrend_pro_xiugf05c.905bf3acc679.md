Calculation: ATR = average true range over a configurable lookback.
Calculation: Volatility regime = Low, Normal, or High according to current ATR versus its rolling low and high percentile thresholds, with hysteresis when changing regimes.
Calculation: SuperTrend bands = use the average of high and low as the source; set the basic upper and lower bands to source ± ATR × base multiplier, adjusted downward in the Low regime and upward in the High regime. Trail the upper band downward unless the prior close was above it; trail the lower band upward unless the prior close was below it.
Long: prior trend was bearish AND close > upper SuperTrend band.
Short: prior trend was bullish AND close < lower SuperTrend band.
Exit: Long, close < SuperTrend line.
Exit: Short, close > SuperTrend line.