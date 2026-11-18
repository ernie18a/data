Calculation: body high = max(open, close)
Calculation: long trailing stop = max(body high * (1 - trailing-loss parameter), prior long trailing stop) while long; 0 while flat
Long: datetime is on or after the configured start date AND SMA(close, shortest MA lookback) crosses above SMA(close, second-longest MA lookback)
Long: SMA(close, shortest MA lookback) crosses above SMA(close, second-longest MA lookback) AND RSI(close, RSI lookback) > RSI threshold parameter AND (SMA(close, second-shortest MA lookback) >= SMA(close, longest MA lookback) OR SMA(close, second-longest MA lookback) >= SMA(close, longest MA lookback))
Short: SMA(close, shortest MA lookback) crosses below SMA(close, second-longest MA lookback)
Exit: long, close < entry price * stop-loss activation parameter
Exit: long, body high >= entry price * profit-activation parameter AND close <= long trailing stop