Calculation: Minervini score = count of the following 8 conditions that are true:
Calculation: Close > short-term SMA, medium-term SMA, and long-term SMA
Calculation: Short-term SMA > medium-term SMA > long-term SMA
Calculation: Long-term SMA has increased on every bar across a longer lookback
Calculation: Close >= rolling low over a long-term lookback × (1 + threshold)
Calculation: Close >= rolling high over a long-term lookback × (1 − threshold)
Calculation: Clamp(50 + 1.2 × percentage return over a lookback, 0, 100) >= threshold
Calculation: Volume >= average volume over a lookback × multiplier
Calculation: Close > close at both a longer lookback and a shorter lookback
Long: Minervini score = 8
Exit: long or short, Minervini score <= 3