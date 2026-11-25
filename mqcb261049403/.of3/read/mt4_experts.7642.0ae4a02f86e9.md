Calculation: prior-session high = MAX(high over the previous session from T1 last completed bars, using the session-boundary parameter)
Calculation: prior-session low = MIN(low over the previous session from T1 last completed bars, using the session-boundary parameter)
Long: close != prior-session low
Short: close != prior-session high
Long: SMMA(close, shorter lookback, T1, last completed bar) crosses above SMMA(close, longer lookback, T1, last completed bar) OR SMMA(close, shorter lookback, T2, last completed bar) crosses above SMMA(close, longer lookback, T2, last completed bar)
Short: SMMA(close, shorter lookback, T1, last completed bar) crosses below SMMA(close, longer lookback, T1, last completed bar) OR SMMA(close, shorter lookback, T2, last completed bar) crosses below SMMA(close, longer lookback, T2, last completed bar)
Exit: long, position side = long
Exit: short, position side = short