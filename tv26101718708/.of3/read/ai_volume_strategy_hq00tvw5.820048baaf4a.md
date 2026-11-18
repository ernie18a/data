Long: volume > EMA(volume, volume lookback) * volume multiplier AND close > EMA(close, price lookback) AND close > open
Short: volume > EMA(volume, volume lookback) * volume multiplier AND close < EMA(close, price lookback) AND close < open
Exit: long, bars since entry >= exit lookback
Exit: short, bars since entry >= exit lookback