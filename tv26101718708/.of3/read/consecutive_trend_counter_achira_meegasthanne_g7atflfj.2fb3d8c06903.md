Calculation: Bullish count = consecutive chart bars where EMA(close, fast lookback) > WMA(close, slow lookback), reset to zero otherwise
Calculation: Bearish count = consecutive chart bars where EMA(close, fast lookback) < WMA(close, slow lookback), reset to zero otherwise
Calculation: T1 fast EMA = EMA(close, fast lookback) on T1 bars, using the current bar (still forming in real time) and mapping values to chart bars; T1 is shorter than T2
Calculation: T1 slow WMA = WMA(close, slow lookback) on T1 bars, using the current bar (still forming in real time) and mapping values to chart bars
Calculation: T2 fast EMA = EMA(close, fast lookback) on T2 bars, using the current bar (still forming in real time) and mapping values to chart bars
Calculation: T2 slow WMA = WMA(close, slow lookback) on T2 bars, using the current bar (still forming in real time) and mapping values to chart bars
Long: Bullish count >= trend threshold AND T1 fast EMA > T1 slow WMA AND T2 fast EMA > T2 slow WMA
Short: Bearish count >= trend threshold AND T1 fast EMA < T1 slow WMA AND T2 fast EMA < T2 slow WMA
Long: Bullish count >= trend threshold AND (T1 fast EMA <= T1 slow WMA OR T2 fast EMA <= T2 slow WMA)
Short: Bearish count >= trend threshold AND (T1 fast EMA >= T1 slow WMA OR T2 fast EMA >= T2 slow WMA)