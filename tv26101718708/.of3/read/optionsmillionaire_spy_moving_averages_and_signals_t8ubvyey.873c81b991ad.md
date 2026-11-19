Long: on chart bars, MA(close, shorter lookback, short MA type, T1, last completed bar) > MA(close, longer lookback, long MA type, T1, last completed bar)
Short: on chart bars, MA(close, shorter lookback, short MA type, T1, last completed bar) < MA(close, longer lookback, long MA type, T1, last completed bar)
Exit: long, low <= entry price * (1 - stop-loss percentage) OR high >= entry price * (1 + profit-target percentage)
Exit: short, high >= entry price * (1 + stop-loss percentage) OR low <= entry price * (1 - profit-target percentage)