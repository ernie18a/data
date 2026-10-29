Calculation: Volume-weighted price = sum(selected applied price × selected volume) / max(sum(selected volume), 1) over a shorter lookback
Calculation: Normalized range position = 100 × (current volume-weighted price − lowest volume-weighted price) / (highest volume-weighted price − lowest volume-weighted price) − 50 over a longer lookback; when the highest and lowest are equal, use −50
Calculation: First smoothed value = selected smoothing of normalized range position
Calculation: Second smoothed value = the same smoothing of the first smoothed value, using the same method and length
Long: First smoothed value > second smoothed value
Short: First smoothed value <= second smoothed value