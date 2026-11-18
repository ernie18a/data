Calculation: Stop = close < open ? high : low, evaluated on the entry bar
Long: (close crosses above EMA(close, lookback, T1, last completed bar) OR close crosses below EMA(close, lookback, T1, last completed bar)) AND close > open
Short: (close crosses above EMA(close, lookback, T1, last completed bar) OR close crosses below EMA(close, lookback, T1, last completed bar)) AND close < open
Exit: Long, low <= Stop
Exit: Short, high >= Stop