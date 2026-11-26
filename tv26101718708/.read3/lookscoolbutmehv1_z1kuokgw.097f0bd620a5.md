Calculation: Chart EMA = EMA(close, long lookback)
Calculation: T1 EMA = EMA(T1 close mapped onto chart bars, the same long lookback, using the available T1 close including its still-forming value)
Calculation: T2 EMA = EMA(T2 close mapped onto chart bars, shorter lookback, using the available T2 close including its still-forming value); T2 is longer than T1
Long: Chart EMA > T1 EMA AND T1 EMA > T2 EMA AND datetime >= start datetime AND datetime <= end datetime
Short: Chart EMA > T1 EMA AND T1 EMA < T2 EMA AND datetime >= start datetime AND datetime <= end datetime
Exit: long, low <= entry price - stop-loss distance in ticks OR high >= entry price + profit-target distance in ticks
Exit: short, high >= entry price + stop-loss distance in ticks OR low <= entry price - profit-target distance in ticks