Calculation: volume-weighted body expansion = body-size parameter × EMA(volume, volume-smoothing lookback) / (EMA(volume, volume-smoothing lookback) + EMA(volume, volume-smoothing lookback)[1])
Calculation: upper boundary = max(open, close) + volume-weighted body expansion × abs(close − open)
Calculation: lower boundary = min(open, close) − volume-weighted body expansion × abs(close − open)
Long: signal display enabled AND high > upper boundary AND low > lower boundary AND close != open
Short: signal display enabled AND high < upper boundary AND low < lower boundary AND close != open