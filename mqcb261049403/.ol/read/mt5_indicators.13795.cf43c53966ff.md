Calculation: Hi-Lo Range(N) = 100 × (current bar midpoint − lowest low over N bars) ÷ (highest high over N bars − lowest low over N bars); use 0 if the range is zero. Include the current, possibly forming bar.
Calculation: Fast trend = weighted sum of five Hi-Lo Range values with progressively longer lookbacks.
Calculation: Slow trend = fast trend ÷ smoothing period + previous bar’s slow trend × (smoothing period − 1) ÷ smoothing period.
Long: Fast trend > slow trend
Short: Fast trend < slow trend
Long: On a higher timeframe, fast trend > slow trend, using the higher timeframe bar still forming
Short: On a higher timeframe, fast trend < slow trend, using the higher timeframe bar still forming