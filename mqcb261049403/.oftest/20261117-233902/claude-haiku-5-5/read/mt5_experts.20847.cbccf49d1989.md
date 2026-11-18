Calculation: shifted_sma = SMA(close x[shift], lookback)
Long: no position is open AND bar count > minimum history AND open x[1] < shifted_sma AND close x[1] > shifted_sma
Short: no position is open AND bar count > minimum history AND open x[1] > shifted_sma AND close x[1] < shifted_sma
Exit: Long, low x[0] <= entry price - stop distance
Exit: Long, high x[0] >= entry price + target distance
Exit: Short, high x[0] >= entry price + stop distance
Exit: Short, low x[0] <= entry price - target distance