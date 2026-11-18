Long: EMA(close, lookback) crosses above VWAP(hlc3) AND volume >= SMA(volume, lookback) * multiplier AND ATR(lookback) >= minimum points
Short: EMA(close, lookback) crosses below VWAP(hlc3) AND volume >= SMA(volume, lookback) * multiplier AND ATR(lookback) >= minimum points
Exit: long, EMA(close, lookback) crosses below VWAP(hlc3)
Exit: short, EMA(close, lookback) crosses above VWAP(hlc3)