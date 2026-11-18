Long: volume > SMA(volume, lookback) AND close > open AND volume > volume[1] AND volume[1] > SMA(volume, lookback) AND close[1] > open[1]
Exit: long, high >= entry price + target move