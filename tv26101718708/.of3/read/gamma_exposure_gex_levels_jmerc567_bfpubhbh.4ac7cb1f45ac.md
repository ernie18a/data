Calculation: Volume imbalance = EMA(if SUM(volume when close >= open, volume lookback) + SUM(volume when close < open, volume lookback) != 0 then (SUM(volume when close >= open, volume lookback) - SUM(volume when close < open, volume lookback)) / (SUM(volume when close >= open, volume lookback) + SUM(volume when close < open, volume lookback)) else 0, signal smoothing)
Calculation: Volume imbalance momentum = Volume imbalance - Volume imbalance[momentum lag]
Long: Volume imbalance > 0
Short: Volume imbalance <= 0
Long: Volume imbalance momentum > 0
Short: Volume imbalance momentum <= 0