Calculation: Imbalance = (SUM(volume if close > close[1] else 0, imbalance lookback) - SUM(volume if close < close[1] else 0, imbalance lookback)) / SUM(volume, imbalance lookback), or NA when SUM(volume, imbalance lookback) is zero
Long: Imbalance >= 0
Short: Imbalance < 0