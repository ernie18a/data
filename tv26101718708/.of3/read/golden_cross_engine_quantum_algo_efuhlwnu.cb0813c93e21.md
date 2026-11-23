Calculation: Slope(x, n) = (x - x[n]) / n
Calculation: MA spread = MA(close, fast length, MA type) - MA(close, slow length, MA type)
Calculation: Bars to meet = abs(MA spread) / abs(Slope(MA spread, countdown slope lookback))
Calculation: Golden countdown = MA spread < 0 AND Slope(MA spread, countdown slope lookback) > 0 AND 1 <= Bars to meet <= max countdown bars
Calculation: Death countdown = MA spread > 0 AND Slope(MA spread, countdown slope lookback) < 0 AND 1 <= Bars to meet <= max countdown bars
Calculation: Golden approach = Golden countdown AND Bars to meet <= approach lead bars
Calculation: Death approach = Death countdown AND Bars to meet <= approach lead bars
Calculation: Volume z-score = 0 when STDEV(volume, volume lookback) is undefined or zero, else (volume - SMA(volume, volume lookback)) / STDEV(volume, volume lookback)
Long: MA spread crosses above 0
Long: MA spread crosses above 0 AND Volume z-score > volume z threshold AND abs(Slope(MA(close, fast length, MA type), grade slope lookback)) / ATR(high, low, close, ATR length) > steepness threshold AND close > MA(close, fast length, MA type)
Long: Golden countdown
Long: Golden approach AND NOT Golden approach[1]
Long: MA spread > 0
Long: MA(close, fast length, MA type, T1, last completed bar) > MA(close, slow length, MA type, T1, last completed bar)
Long: MA(close, fast length, MA type, T2, last completed bar) > MA(close, slow length, MA type, T2, last completed bar)
Long: MA(close, fast length, MA type, T3, last completed bar) > MA(close, slow length, MA type, T3, last completed bar)
Long: MA(close, fast length, MA type, T4, last completed bar) > MA(close, slow length, MA type, T4, last completed bar)
Long: MA(close, fast length, MA type, T5, last completed bar) > MA(close, slow length, MA type, T5, last completed bar)
Short: MA spread crosses below 0
Short: MA spread crosses below 0 AND Volume z-score > volume z threshold AND abs(Slope(MA(close, fast length, MA type), grade slope lookback)) / ATR(high, low, close, ATR length) > steepness threshold AND close < MA(close, fast length, MA type)
Short: Death countdown
Short: Death approach AND NOT Death approach[1]
Short: MA spread <= 0
Short: MA(close, fast length, MA type, T1, last completed bar) <= MA(close, slow length, MA type, T1, last completed bar)
Short: MA(close, fast length, MA type, T2, last completed bar) <= MA(close, slow length, MA type, T2, last completed bar)
Short: MA(close, fast length, MA type, T3, last completed bar) <= MA(close, slow length, MA type, T3, last completed bar)
Short: MA(close, fast length, MA type, T4, last completed bar) <= MA(close, slow length, MA type, T4, last completed bar)
Short: MA(close, fast length, MA type, T5, last completed bar) <= MA(close, slow length, MA type, T5, last completed bar)