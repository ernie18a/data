Long: On each tick, using the last completed T1 bar and the bar before it, EMA(close, shorter lookback, T1) crosses above EMA(close, longer lookback, T1)
Short: On each tick, using the last completed T1 bar and the bar before it, EMA(close, shorter lookback, T1) crosses below EMA(close, longer lookback, T1)
Exit: long, bid <= entry price - stop-loss distance OR bid >= entry price + take-profit distance
Exit: short, ask >= entry price + stop-loss distance OR ask <= entry price - take-profit distance