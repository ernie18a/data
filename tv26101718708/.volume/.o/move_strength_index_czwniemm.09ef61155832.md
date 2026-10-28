Calculation: Relative volume = current bar volume / Wilder RMA of volume from prior bars, excluding the current bar
Calculation: Volume percentile rank = percentile rank of current relative volume over the trailing lookback, including the current bar
Calculation: Range ratio = current bar high-low range / Wilder RMA of true range
Long: close >= open AND volume percentile rank >= strong-signal threshold AND range ratio > narrow-range threshold
Short: close < open AND volume percentile rank >= strong-signal threshold AND range ratio > narrow-range threshold