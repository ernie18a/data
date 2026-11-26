Long: EMA(close, fast lookback) crosses above EMA(close, slow lookback) AND close > EMA(close, fast lookback) AND volume * volume multiplier > SMA(volume, volume-average lookback)[1]
Short: EMA(close, fast lookback) crosses below EMA(close, slow lookback) AND close < EMA(close, fast lookback) AND volume * volume multiplier > SMA(volume, volume-average lookback)[1]
Exit: long, close < EMA(close, fast lookback)
Exit: short, close > EMA(close, fast lookback)