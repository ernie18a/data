Calculation: Volume ratio = current volume divided by its moving average, clamped to [0.35, 2.50]
Calculation: Hybrid line = EMA(close) × weight + (EMA(close) + ((close − EMA(close)) / standard deviation(close) × ATR × 0.35)) × (1 − weight)
Calculation: Upper Band 1 = Hybrid line + (standard deviation(close) × 0.65 + ATR × 0.35) × (upper base multiplier + (Volume ratio − 1) × upper volume impact)
Calculation: Lower Band 1 = Hybrid line − (standard deviation(close) × 0.65 + ATR × 0.35) × (lower base multiplier + (Volume ratio − 1) × lower volume impact)
Calculation: Upper Band 2 = Hybrid line + (Upper Band 1 − Hybrid line) × 1.55
Calculation: Lower Band 2 = Hybrid line − (Hybrid line − Lower Band 1) × 1.40
Long: close > Upper Band 1 AND previous close ≤ previous Upper Band 1 AND Hybrid line > previous Hybrid line
Short: close < Lower Band 1 AND previous close ≥ previous Lower Band 1 AND Hybrid line < previous Hybrid line
Exit: Long, close > Upper Band 2 AND low > Upper Band 1 AND NOT (previous close > previous Upper Band 2 AND previous low > previous Upper Band 1)
Exit: Short, close < Lower Band 2 AND high < Lower Band 1 AND NOT (previous close < previous Lower Band 2 AND previous high < previous Lower Band 1)