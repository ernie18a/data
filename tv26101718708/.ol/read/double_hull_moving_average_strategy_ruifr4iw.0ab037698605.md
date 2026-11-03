Calculation: Hull moving average (HMA) = WMA(2 × WMA(close, rounded half lookback) − WMA(close, lookback), rounded square root of lookback)
Long: short-lookback HMA > long-lookback HMA AND datetime >= configured start datetime AND datetime <= configured end datetime
Exit: long, short-lookback HMA < long-lookback HMA AND datetime >= configured start datetime AND datetime <= configured end datetime