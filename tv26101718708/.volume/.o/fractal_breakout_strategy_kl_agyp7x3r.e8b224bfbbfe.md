Calculation: Confirmed fractal support = the low of the latest pivot bar where its low is below the lows of the two preceding bars and the two following bars, and its volume exceeds the six-bar SMA of volume at the pivot; retain this level until a newer pivot qualifies
Calculation: ATR deviation statistic = (short-lookback ATR − long-lookback ATR) / (short-lookback standard deviation of true range / square root of the short lookback)
Calculation: Initial risk = ATR × trailing-stop multiplier, measured at entry
Calculation: Trailing stop = the highest value since entry of (bar low − ATR × trailing-stop multiplier)
Long: close ≥ confirmed fractal support AND ATR deviation statistic < −critical value
Exit: long, low ≤ trailing stop
Exit: long, take-profit mode is enabled AND close > average entry price AND close ≥ initial entry price + first profit level × initial risk AND no prior profit level has been taken
Exit: long, take-profit mode is enabled AND close > average entry price AND close ≥ initial entry price + second profit level × initial risk AND exactly one prior profit level has been taken
Exit: long, take-profit mode is enabled AND close > average entry price AND close ≥ initial entry price + third profit level × initial risk AND exactly two prior profit levels have been taken