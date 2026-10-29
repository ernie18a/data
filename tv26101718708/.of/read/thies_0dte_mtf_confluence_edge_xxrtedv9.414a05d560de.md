Calculation: Relative volume = volume / simple moving average of volume over its lookback.
Calculation: Signed pressure EMA = exponential moving average of relative volume × normalized close location, where normalized close location = 2 × (close − low) / (high − low) − 1, or 0 when high = low.
Calculation: Combined relative volume = mean of the relative volumes from the two confirmation series.
Calculation: Combined pressure = sum of the signed pressure EMAs from the two confirmation series.
Long: Within the configured session AND, on any of the four configured timeframes, combined relative volume > its configured minimum AND combined pressure > 0 AND both confirmation series close > open.
Short: Within the configured session AND, on any of the four configured timeframes, combined relative volume > its configured minimum AND combined pressure < 0 AND both confirmation series close < open.
Exit: 