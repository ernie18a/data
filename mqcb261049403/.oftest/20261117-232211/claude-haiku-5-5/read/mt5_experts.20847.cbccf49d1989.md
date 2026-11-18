Calculation: shifted_sma = SMA(close, period)[shift]
Long: open[1] < shifted_sma AND close[1] > shifted_sma
Short: open[1] > shifted_sma AND close[1] < shifted_sma
Exit: long, low <= entry price - stop loss parameter * point size
Exit: long, high >= entry price + take profit parameter * point size
Exit: short, high >= entry price + stop loss parameter * point size
Exit: short, low <= entry price - take profit parameter * point size