Calculation: Smoothed range = EMA(EMA(abs(close − prior close), L), 2L − 1) × multiplier
Calculation: Volume-adjusted range filter = if volume > prior volume, max(close − smoothed range, prior filter); otherwise, min(close + smoothed range, prior filter)
Calculation: Upper band = volume-adjusted range filter + smoothed range
Calculation: Lower band = volume-adjusted range filter − smoothed range
Calculation: Range-supertrend uptrend = bars since close crossed above the prior rolling highest upper band < bars since close crossed below the prior rolling lowest lower band
Long: volume-adjusted range filter > prior volume-adjusted range filter AND close crosses above upper band AND (range-supertrend filter disabled OR range-supertrend uptrend) AND (ADX filter disabled OR ADX > VWMA of ADX) AND (VWMA filter disabled OR volume-adjusted range filter > its VWMA)
Exit: Long, volume-adjusted range filter ≤ prior volume-adjusted range filter AND close crosses below lower band AND (range-supertrend filter disabled OR NOT range-supertrend uptrend) AND (ADX filter disabled OR ADX > VWMA of ADX)