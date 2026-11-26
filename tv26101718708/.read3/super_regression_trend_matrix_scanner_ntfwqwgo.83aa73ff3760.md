Calculation: Regression trend state = initialize bullish; regression = linear regression(close, lookback); RMSE = sqrt(sum(i=0 to lookback−1, (close[i]−regression[i])²)/(lookback−1)); raw upper/lower bands = regression ± RMSE × multiplier; each bar, upper band = min(raw upper band, previous upper band) if previous state is bearish, otherwise raw upper band; lower band = max(raw lower band, previous lower band) if previous state is bullish, otherwise raw lower band; switch bullish to bearish when close < lower band, bearish to bullish when close > upper band, otherwise retain previous state
Long: Regression trend state is bullish
Long: Regression trend state changes from bearish to bullish
Short: Regression trend state is bearish
Short: Regression trend state changes from bullish to bearish