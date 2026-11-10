Calculation: Imbalance = 100 × rolling sum of volume × (2 × (close − low) / (high − low) − 1) divided by the rolling sum of volume; use −1 for the parenthesized value when high = low, and 0 for imbalance when the volume sum is 0.
Calculation: Upper and lower thresholds = rolling linearly interpolated upper and lower percentiles of imbalance, respectively; for current-bar classifications, replace an unavailable threshold with 0.
Long: Imbalance >= 0.
Short: Imbalance < 0.
Long: Imbalance > upper threshold.
Short: Imbalance <= upper threshold AND imbalance < lower threshold.
Long: Close > SMA of close.
Short: Close < SMA of close.
Long: Previous-bar imbalance > previous-bar upper threshold AND (trend filter disabled OR previous-bar close > previous-bar SMA of close) AND bars since the last long extreme signal >= cooldown.
Short: Previous-bar imbalance < previous-bar lower threshold AND (trend filter disabled OR previous-bar close < previous-bar SMA of close) AND bars since the last short extreme signal >= cooldown.