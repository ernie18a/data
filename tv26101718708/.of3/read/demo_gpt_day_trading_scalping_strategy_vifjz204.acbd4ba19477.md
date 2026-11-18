Long: close[1] > open[1] AND close > open AND open > close[1] AND volume > SMA(volume, lookback)
Exit: long, close[1] < open[1] AND close < open AND open < close[1] AND volume > SMA(volume, lookback)