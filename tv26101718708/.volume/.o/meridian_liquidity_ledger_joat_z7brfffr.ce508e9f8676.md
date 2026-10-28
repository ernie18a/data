Calculation: Reference = EMA(close) when the adaptive anchor band is disabled; otherwise, EMA(close) minus 0.20 × standard deviation(close) × bias when close ≥ EMA, or plus that amount when close < EMA
Calculation: Ledger imbalance = (sum of volume on bars where close ≥ open − sum of volume on bars where close < open) / max(sum of volume over the same rolling lookback, 1)
Calculation: Outer anchor bands = Reference ± 1.10 × standard deviation(close), using the same deviation lookback as the adaptive anchor
Long: bar is confirmed AND (Ledger imbalance > 0.12 AND close ≥ Reference OR close > upper outer anchor band AND Ledger imbalance > 0)
Short: bar is confirmed AND (Ledger imbalance < −0.12 AND close ≤ Reference OR close < lower outer anchor band AND Ledger imbalance < 0)