Long: RSI(close, lookback) < oversold-threshold parameter AND RSI(close, lookback)[1] > RSI(close, lookback)
Short: RSI(close, lookback) > overbought-threshold parameter AND RSI(close, lookback)[1] < RSI(close, lookback)
Exit: Long, high >= entry price + profit-target parameter (ticks) OR low <= entry price - stop-loss parameter (ticks)
Exit: Short, low <= entry price - profit-target parameter (ticks) OR high >= entry price + stop-loss parameter (ticks)