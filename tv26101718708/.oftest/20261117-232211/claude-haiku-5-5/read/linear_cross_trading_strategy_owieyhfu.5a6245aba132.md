Calculation: Predicted = SMA(close, L) + SUM((volume - SMA(volume, L)) * (close - SMA(close, L)), L) / SUM((volume - SMA(volume, L))^2, L) * (volume - SMA(volume, L))
Calculation: MACD = EMA(Predicted, shorter lookback) - EMA(Predicted, longer lookback)
Calculation: Signal = EMA(MACD, signal lookback)
Long: Predicted crosses above WMA(Predicted, W) AND Signal < MACD AND MACD > MACD[1] AND MACD[1] > MACD[2]
Short: Signal > MACD AND MACD < MACD[1] AND low < low[1] AND low[1] < low[2]