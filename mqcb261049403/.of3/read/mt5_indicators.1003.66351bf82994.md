Long: XRSX(close, lookback) > 0 AND XRSX(close, lookback) != XRSX(close, lookback)[1]
Short: XRSX(close, lookback) < 0 AND XRSX(close, lookback) != XRSX(close, lookback)[1]
Long: XRSX(close, lookback) > XRSX signal line[1]
Short: XRSX(close, lookback) < XRSX signal line[1]
Long: On chart bars using T1 values, XRSX(close, lookback) > 0 AND XRSX(close, lookback, T1, last completed bar) != XRSX(close, lookback, T1, bar still forming)
Short: On chart bars using T1 values, XRSX(close, lookback) < 0 AND XRSX(close, lookback, T1, last completed bar) != XRSX(close, lookback, T1, bar still forming)
Long: XRSX(close, lookback) > XRSX signal line
Short: XRSX(close, lookback) < XRSX signal line