Calculation: N-bar return = 100 * (close - close[N]) / close[N] on T1 bars, evaluated on each completed T1 bar
Calculation: Eligible T1 bar = every bar in rolling mode; in isolated mode, every bar except the next N-1 bars after a Bullish or Bearish observation; in non-overlapping mode, every bar except the next N-1 bars after any observation
Calculation: T1 observation state = Bullish when N-bar return > threshold, Bearish when N-bar return < -threshold, otherwise Neutral, on eligible T1 bars
Long: T1 >= chart timeframe AND eligible T1 observation state is Bullish
Short: T1 >= chart timeframe AND eligible T1 observation state is Bearish
Calculation: Latest state = state of the most recent eligible completed T1 observation
Calculation: Transition probability(S,X) = count of eligible-observation pairs with earlier state S and later state X, separated by the candle-difference parameter, divided by all such pairs with earlier state S; zero when the denominator is zero
Long: Transition probability(latest state,Bullish) > Transition probability(latest state,Bearish)
Short: Transition probability(latest state,Bullish) < Transition probability(latest state,Bearish)