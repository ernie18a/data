Calculation: RSI = RSI of close
Calculation: FastMA = moving average of RSI, short lookback
Calculation: SlowMA = moving average of RSI, long lookback (longer than FastMA)
Calculation: CloseMA = moving average of close
Calculation: Levels = oversold < mid < overbought, fixed RSI thresholds
Long: RSI crosses above SlowMA
Long: FastMA crosses above SlowMA
Long: RSI crosses above SlowMA AND FastMA crosses above SlowMA on the same bar
Long: SlowMA crosses above mid level
Long: RSI crosses above mid level
Long: RSI crosses above SlowMA AND RSI < oversold on the current bar or any of the previous 5 bars
Long: RSI crosses above oversold level
Long: close crosses above CloseMA AND RSI crosses above SlowMA on the same bar
Exit: long, RSI crosses below SlowMA
Exit: long, FastMA crosses below SlowMA
Exit: long, RSI crosses below SlowMA AND FastMA crosses below SlowMA on the same bar
Exit: long, SlowMA crosses below mid level
Exit: long, RSI crosses below mid level
Exit: long, FastMA crosses below SlowMA AND RSI > overbought on the current bar or any of the previous 5 bars
Exit: long, RSI crosses below overbought level OR RSI crosses below oversold level
Exit: long, close crosses below CloseMA AND RSI crosses below SlowMA on the same bar
Exit: long, price <= entry price * (1 - stop-loss fraction) OR price >= entry price * (1 + take-profit fraction), where take-profit fraction > stop-loss fraction