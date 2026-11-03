Calculation: Hi-Lo range oscillator = 100 × (current bar's (high + low) / 2 − lowest low over the lookback) / (highest high over the lookback − lowest low over the lookback); use 0 when the denominator is 0.
Calculation: Fast trend = weighted sum of five hi-lo range oscillators with progressively longer lookbacks; the second and third oscillators share the same weight.
Calculation: Slow trend = fast trend / smoothing period + previous slow trend × (smoothing period − 1) / smoothing period; initialize it to the first fast trend / smoothing period.
Calculation: Higher-timeframe trends = fast trend and slow trend calculated on the higher timeframe using its still-forming bar, with the resulting values mapped to its constituent chart bars.
Long: Fast trend > slow trend OR higher-timeframe fast trend > higher-timeframe slow trend.
Short: Fast trend < slow trend OR higher-timeframe fast trend < higher-timeframe slow trend.