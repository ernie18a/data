Long: close[1] > open[1] AND volume[1] > SMA(volume, lookback) AND close > open AND volume > SMA(volume, lookback) AND volume > volume[1]
Exit: Long, high >= entry price + target move