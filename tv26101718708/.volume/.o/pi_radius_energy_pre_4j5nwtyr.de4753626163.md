Calculation: PI-radius energy = EMA of the 0–100 min–max normalization of π × ATR² × signed square root of the absolute OBV rate of change; use 50 when the normalization range is zero. OBV accumulates volume positively when close rises, negatively when it falls, and unchanged when close is unchanged.
Calculation: Energy average = EMA of PI-radius energy.
Calculation: Long-term energy EMA = longer-lookback EMA of PI-radius energy than the energy average.
Calculation: Energy spread = PI-radius energy − (energy average + buffer).
Calculation: ATR rank and volume rank = percentile ranks of ATR and volume over the same lookback.
Calculation: Momentum Z-score = (close rate of change − its rolling mean) ÷ its rolling standard deviation; use 0 when the standard deviation is zero.
Calculation: Filter passes = ATR rank and volume rank are each at least their respective minimums, and momentum Z-score is at least its minimum.
Calculation: Squeeze = rolling standard deviation of PI-radius energy is below its moving average multiplied by a sensitivity factor; recent squeeze = squeeze occurred within the current or previous six bars.
Calculation: Bottom zone ready = PI-radius energy is below a threshold or its rolling low over a short lookback is below that threshold.
Calculation: OBV momentum rises = signed square root of the absolute OBV rate of change is greater than its prior-bar value.
Long: energy spread > 0 OR PI-radius energy > long-term energy EMA OR (filter passes AND PI-radius energy > long-term energy EMA AND recent squeeze AND bottom zone ready AND PI-radius energy > its prior-bar value AND its prior-bar value ≤ its value two bars ago AND OBV momentum rises) OR (filter passes AND PI-radius energy > long-term energy EMA AND PI-radius energy crosses above energy average + buffer AND recent squeeze) OR (filter passes AND PI-radius energy > long-term energy EMA AND energy spread > 0 AND absolute energy spread ≥ a threshold AND PI-radius energy > its prior-bar value AND OBV momentum rises)
Short: energy spread < 0