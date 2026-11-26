Calculation: Normalized return = ((close-close[1])/close[1]) / stdev((close-close[1])/close[1], lookback)[1], calculated on T1 bars at the selected period offset (current still-forming T1 bar or previous completed T1 bar) and sampled on chart bars from T1
Long: Normalized return > threshold
Long: Normalized return >= 0 AND Normalized return <= threshold
Short: Normalized return < -threshold
Short: Normalized return < 0 AND Normalized return >= -threshold