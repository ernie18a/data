Calculation: Volume-weighted weighted-close average = sum(weighted close × volume) / sum(volume) over a shorter lookback; weighted close = (2 × close + high + low) / 4. Use the configured volume series.
Calculation: Normalized range value = 100 × (volume-weighted weighted-close average − lowest average over a longer lookback) / max(highest average − lowest average over that lookback, minimum price increment) − 50.
Calculation: First smoothed value = apply the configured smoother to the normalized range value; second smoothed value = apply the same smoother with the same parameters to the first smoothed value.
Long: First smoothed value > second smoothed value AND previous bar's first smoothed value <= previous bar's second smoothed value
Short: First smoothed value <= second smoothed value AND previous bar's first smoothed value >= previous bar's second smoothed value
Exit: Short, Long condition
Exit: Long, Short condition OR low <= entry price − stop distance OR high >= entry price + target distance
Exit: Short, Long condition OR high >= entry price + stop distance OR low <= entry price − target distance