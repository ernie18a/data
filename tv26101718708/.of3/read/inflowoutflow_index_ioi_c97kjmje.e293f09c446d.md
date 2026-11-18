Calculation: Positive body-flow EMA = EMA(max(volume * (close - open), 0), lookback)
Calculation: Negative body-flow EMA = EMA(max(volume * (open - close), 0), lookback)
Long: Negative body-flow EMA = 0 OR Positive body-flow EMA > Negative body-flow EMA
Short: Negative body-flow EMA > Positive body-flow EMA