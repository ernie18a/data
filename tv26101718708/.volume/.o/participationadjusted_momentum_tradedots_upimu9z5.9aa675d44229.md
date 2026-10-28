Calculation: Standardized momentum = z-score of close rate-of-change over a shorter lookback, normalized over a longer lookback
Calculation: Volume percentile = percentile rank of volume over the normalization lookback
Calculation: Participation = volume percentile × direction-aligned close location within the bar; use close location for positive momentum, 1 minus close location for negative momentum, and 0.5 for zero momentum
Long: standardized momentum ≥ strong-momentum threshold AND participation ≥ 0.55
Short: standardized momentum ≤ −strong-momentum threshold AND participation ≥ 0.55