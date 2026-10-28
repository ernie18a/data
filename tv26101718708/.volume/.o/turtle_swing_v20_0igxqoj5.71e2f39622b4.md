Calculation: Shorter breakout level = highest high over a shorter lookback, using the last completed bar's value
Calculation: Longer breakout level = highest high over a longer lookback, using the last completed bar's value
Calculation: Entry volume average = simple moving average of volume over a lookback
Calculation: ATR stop level = entry price minus a multiple of average true range
Calculation: Shorter exit level = lowest low over a shorter lookback, including the current bar
Calculation: Longer exit level = lowest low over a longer lookback, including the current bar
Calculation: EMA slope = current EMA is greater than its value several bars earlier
Long: close > shorter breakout level AND close > EMA AND volume >= entry volume average × a threshold AND RSI > a threshold
Long: close > longer breakout level AND close > EMA AND volume >= entry volume average × a threshold AND RSI > a threshold
Long: while long, close >= initial entry price + (number of units already held × a fraction of ATR) AND EMA slope is rising, up to a maximum number of units
Exit: long, low <= ATR stop level
Exit: long, low <= shorter exit level
Exit: long, low <= longer exit level
Exit: long, close < EMA