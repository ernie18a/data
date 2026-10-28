Calculation: Smoothed range = EMA(EMA(|close − prior close|, lookback) × multiplier, 2 × lookback − 1)
Calculation: Volume-adjusted range filter = if volume > prior volume, max(close − smoothed range, prior filter); otherwise min(close + smoothed range, prior filter). Initialize prior filter to 0.
Calculation: Upper and lower range bands = volume-adjusted range filter + smoothed range; volume-adjusted range filter − smoothed range
Calculation: Range trend = volume-adjusted range filter > its prior-bar value
Calculation: ADX filter = ADX > VWMA of ADX, using the same lookback for both; apply only when enabled
Calculation: Range uptrend = bars since close crossed above the prior-bar lowest lower band < bars since close crossed below the prior-bar highest upper band, with both extrema using the same lookback; apply the uptrend condition to long entries and its inverse to exits only when enabled
Calculation: Volume filter = volume-adjusted range filter > its VWMA, using the same lookback; apply only to long entries when enabled
Long: Range trend AND close crosses above the upper range band AND (range uptrend when enabled) AND (ADX filter when enabled) AND (volume filter when enabled)
Exit: long, NOT Range trend AND close crosses below the lower range band AND (NOT range uptrend when enabled) AND (ADX filter when enabled)