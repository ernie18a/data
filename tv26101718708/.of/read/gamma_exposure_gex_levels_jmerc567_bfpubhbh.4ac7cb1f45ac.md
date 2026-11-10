Calculation: Volume imbalance = (sum of volume on bars with close >= open over a lookback - sum of volume on bars with close < open over the same lookback) / total volume over that lookback; use 0 when total volume is 0.
Calculation: Smoothed volume imbalance = EMA of volume imbalance.
Calculation: Imbalance momentum = smoothed volume imbalance minus its value a specified number of bars ago.
Long: Smoothed volume imbalance > 0.
Short: Smoothed volume imbalance <= 0.
Long: Imbalance momentum > 0.
Short: Imbalance momentum <= 0.