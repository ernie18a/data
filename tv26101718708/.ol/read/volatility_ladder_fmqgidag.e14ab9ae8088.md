Calculation: Volume-weighted price = rolling sum of (average of high, low, close, and close times volume) divided by rolling sum of volume
Calculation: Normalized value = (volume-weighted price − its rolling low over a longer lookback) / (its rolling high over that same longer lookback − its rolling low) × 100
Calculation: Fast line = linear weighted moving average of normalized value, using the same shorter lookback as the volume-weighted price
Calculation: Slow line = linear weighted moving average of the fast line, using the same shorter lookback
Long: Fast line >= slow line
Short: Fast line < slow line