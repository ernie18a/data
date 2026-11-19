Calculation: Estimated buy volume = if high = low then volume / 2 else volume * (close - low) / (high - low)
Calculation: Estimated sell volume = if high = low then volume / 2 else volume * (high - close) / (high - low)
Calculation: DOM bid total = sum for each integer offset k from -level count to +level count of EMA(estimated buy volume, volume smoothing lookback) times current-level weight if k = 0, decay factor^abs(k) * (1 + abs(k) * near-side growth factor) if k < 0, or decay factor^abs(k) * far-side weight if k > 0
Calculation: DOM ask total = sum for each integer offset k from -level count to +level count of EMA(estimated sell volume, volume smoothing lookback) times current-level weight if k = 0, decay factor^abs(k) * (1 + abs(k) * near-side growth factor) if k > 0, or decay factor^abs(k) * far-side weight if k < 0
Calculation: DOM imbalance = round(100 * (DOM bid total - DOM ask total) / (DOM bid total + DOM ask total))
Long: DOM imbalance > imbalance threshold
Short: DOM imbalance < -imbalance threshold