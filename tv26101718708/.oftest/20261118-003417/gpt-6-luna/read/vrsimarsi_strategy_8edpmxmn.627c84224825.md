Long: SMA(RSI(close, lookback), lookback) > SMA(RSI(close, lookback), lookback)[1]
Short: SMA(RSI(close, lookback), lookback) < SMA(RSI(close, lookback), lookback)[1]
Exit: long, SMA(RSI(close, lookback), lookback) < SMA(RSI(close, lookback), lookback)[1]
Exit: short, SMA(RSI(close, lookback), lookback) > SMA(RSI(close, lookback), lookback)[1]