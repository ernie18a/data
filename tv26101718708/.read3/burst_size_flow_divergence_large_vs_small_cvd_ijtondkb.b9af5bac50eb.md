Calculation: Signed sub-bar volume = sign(close − open) × volume, for each sub-bar of T1
Calculation: Mean sub-bar volume = for the current chart bar, sum of volume over its sub-bars of T1 ÷ count of those sub-bars
Calculation: Average sub-bar volume = EMA(Mean sub-bar volume, volume average lookback), updated only on chart bars that have sub-bars of T1
Calculation: Large-tier imbalance = sum of Signed sub-bar volume ÷ sum of volume, over sub-bars of T1 with volume ≥ large-burst multiple × Average sub-bar volume[1], within the last imbalance lookback chart bars including the current one; 0 if that volume sum is 0
Calculation: Small-tier imbalance = sum of Signed sub-bar volume ÷ sum of volume, over sub-bars of T1 with volume ≤ small-burst multiple × Average sub-bar volume[1], within the last imbalance lookback chart bars including the current one; 0 if that volume sum is 0; small-burst multiple < large-burst multiple
Calculation: Smoothed spread = EMA(Large-tier imbalance − Small-tier imbalance, spread smoothing lookback)
Long: Smoothed spread crosses above divergence gate
Short: Smoothed spread crosses below −divergence gate
Long: Smoothed spread ≥ divergence gate
Short: Smoothed spread ≤ −divergence gate
Long: Smoothed spread ≥ 0
Short: Smoothed spread < 0