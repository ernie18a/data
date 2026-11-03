Calculation: Asian High = highest high during the Asian session
Calculation: Asian Low = lowest low during the Asian session
Calculation: Daily ATR = average true range on bars aggregated to a higher timeframe, using the last completed bar
Long: trading session AND not already traded today AND flat AND long direction enabled AND high >= Asian High
Short: trading session AND not already traded today AND flat AND short direction enabled AND low <= Asian Low
Exit: Long, low <= entry price - Daily ATR × stop multiplier OR current bar is outside the trading session AND previous bar was inside it
Exit: Short, high >= entry price + Daily ATR × stop multiplier OR current bar is outside the trading session AND previous bar was inside it