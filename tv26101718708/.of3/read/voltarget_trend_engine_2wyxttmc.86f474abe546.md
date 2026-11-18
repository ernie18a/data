Long: close > SMA(close, regime lookback) AND close[1] <= SMA(close, regime lookback)[1]
Exit: long, close <= SMA(close, regime lookback) AND close[1] > SMA(close, regime lookback)[1]