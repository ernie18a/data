Calculation: Volume-weighted price = rolling sum of (high + low + 2 × close) / 4 × volume divided by rolling sum of volume
Calculation: Normalized position = 100 × (volume-weighted price − its rolling lowest value) / (its rolling highest value − its rolling lowest value)
Calculation: Fast line = linear weighted moving average of normalized position
Calculation: Slow line = linear weighted moving average of fast line, using the same lookback as the fast line
Long: Fast line >= slow line
Short: Fast line < slow line