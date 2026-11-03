Calculation: Session VWAP = cumulative(close × volume) divided by cumulative volume within the current session
Calculation: Stochastic %K = 100 × (close − lowest low over a short lookback) divided by (highest high over the same lookback − lowest low over the same lookback)
Calculation: Long trailing stop = highest close since entry × (1 − trailing-stop percentage)
Long: close < Session VWAP AND Stochastic %K < oversold threshold AND weekday is Sunday, Monday, Tuesday, Friday, or Saturday
Exit: long, low <= Long trailing stop