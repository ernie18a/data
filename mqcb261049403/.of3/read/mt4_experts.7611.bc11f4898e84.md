Calculation: Adjacent EMA spread = EMA(close, longer MACD lookback, T1) - EMA(close, next longer lookback, T1)
Long: MACD(shorter lookback, longer lookback, T1, last completed bar) crosses above zero
Short: MACD(shorter lookback, longer lookback, T1, last completed bar) crosses below zero
Exit: long, chart close on the forming bar is above entry by a profit threshold AND Adjacent EMA spread on the forming T1 bar is less than on the last completed T1 bar
Exit: short, chart close on the forming bar is below entry by a profit threshold AND Adjacent EMA spread on the forming T1 bar is greater than on the last completed T1 bar
Exit: long, price reaches the trailing stop set one trailing distance below the highest price since entry, after price has risen more than the trailing distance
Exit: short, price reaches the trailing stop set one trailing distance above the lowest price since entry, after price has fallen more than the trailing distance