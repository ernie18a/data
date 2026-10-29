Calculation: Volume-weighted average price = volume-weighted average of (high + low + 2 × close) over the shorter lookback
Calculation: Normalized range value = 100 × (current volume-weighted average price − lowest such average over the longer lookback) ÷ (highest − lowest such average over the longer lookback) − 50
Calculation: First smoothed value = normalized range value smoothed once
Calculation: Second smoothed value = first smoothed value smoothed again, using the same smoothing method and length as the first smoothing
Long: First smoothed value > second smoothed value AND first smoothed value on the previous chart bar ≤ second smoothed value on the previous chart bar
Short: First smoothed value ≤ second smoothed value AND first smoothed value on the previous chart bar > second smoothed value on the previous chart bar