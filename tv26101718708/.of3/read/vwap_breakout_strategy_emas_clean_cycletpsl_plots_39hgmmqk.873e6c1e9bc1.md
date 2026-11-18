Calculation: Session VWAP = VWAP
Calculation: ATR value = ATR(lookback)
Calculation: Long stop level = close on long-entry signal bar - ATR value on that bar * stop multiplier
Calculation: Long TP2 level = close on long-entry signal bar + ATR value on that bar * TP2 multiplier
Calculation: Short stop level = close on short-entry signal bar + ATR value on that bar * stop multiplier
Calculation: Short TP2 level = close on short-entry signal bar - ATR value on that bar * TP2 multiplier
Long: close crosses above Session VWAP
Short: close crosses below Session VWAP
Exit: Long, low <= Long stop level OR high >= Long TP2 level
Exit: Short, high >= Short stop level OR low <= Short TP2 level