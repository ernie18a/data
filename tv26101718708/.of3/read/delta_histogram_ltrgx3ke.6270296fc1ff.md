Calculation: Volume delta = if body weighting is enabled, then if high > low, volume * (2 * (close - low) / (high - low) - 1), otherwise 0; otherwise volume if close >= open, or -volume if close < open
Long: Volume delta >= 0
Short: Volume delta < 0