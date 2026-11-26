Calculation: normalized price change = 100 × (close - close[1]) / close
Long: flat AND SMA(normalized price change, lookback) > SMA(normalized price change, lookback)[1] AND SMA(normalized price change, lookback)[1] < -drop threshold AND volume > volume[1]
Exit: long, SMA(normalized price change, lookback) > 0 AND volume[1] > volume