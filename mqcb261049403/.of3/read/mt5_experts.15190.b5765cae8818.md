Long: SMA(close - open, lookback, T1, last completed bar) < 0 AND SMA(close - open, lookback, T1, preceding bar) > 0
Short: SMA(close - open, lookback, T1, last completed bar) > 0 AND SMA(close - open, lookback, T1, preceding bar) < 0
Exit: Long, SMA(close - open, lookback, T1, last completed bar) < 0
Exit: Short, SMA(close - open, lookback, T1, last completed bar) > 0