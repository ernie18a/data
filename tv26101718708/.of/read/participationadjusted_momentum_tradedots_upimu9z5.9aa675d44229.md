Calculation: Raw momentum = z-score of close rate of change over a longer normalization lookback.
Calculation: Participation = volume percentile over the normalization lookback multiplied by direction-aligned close location within the bar; use close location for positive raw momentum, its inverse for negative raw momentum, and 0.5 for zero raw momentum.
Long: Raw momentum ≥ strong-momentum threshold AND participation ≥ 0.55
Short: Raw momentum ≤ −strong-momentum threshold AND participation ≥ 0.55