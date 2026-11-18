Long: position side != long AND min(open, close) > SMA(close, short lookback)
Long: VWAP((high + low + close) / 3) > EMA(close, intermediate lookback)
Short: VWAP((high + low + close) / 3) < EMA(close, intermediate lookback)
Exit: long, close < min(SMA(close, short lookback), EMA(close, intermediate lookback))