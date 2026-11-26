Calculation: Range high = maximum high of chart bars in the current exchange calendar day whose hour is at least the ORB start parameter and below the ORB end parameter
Calculation: Range low = minimum low of chart bars in the current exchange calendar day whose hour is at least the ORB start parameter and below the ORB end parameter
Calculation: Range width = range high - range low
Calculation: Trailing distance = max(ATR(ATR lookback) × ATR multiplier, range width × trailing range fraction)
Long: close > range high AND close[1] <= range high AND bar time is within the session start and end times inclusive in Europe/Amsterdam AND current bar hour is outside the ORB window AND close > EMA(close, trend lookback)
Short: close < range low AND close[1] >= range low AND bar time is within the session start and end times inclusive in Europe/Amsterdam AND current bar hour is outside the ORB window AND close < EMA(close, trend lookback)
Exit: long, low <= range low OR high >= entry + (entry - range low) × reward-risk parameter OR the active long trailing stop is hit using the trailing distance
Exit: short, high >= range high OR low <= entry - (range high - entry) × reward-risk parameter OR the active short trailing stop is hit using the trailing distance