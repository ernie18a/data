Calculation: opening print = open of the first regular-session chart bar
Calculation: active levels = open of each new T2 bar unless it is within a duplicate-tolerance parameter of an existing level; remove a level when a completed T2 close crosses it from the opposite side of the prior completed T2 close
Long: close > EMA(close, shared lookback) on chart bars
Short: close < EMA(close, shared lookback) on chart bars
Long: on chart bars, close from the still-forming T1 bar > EMA(close, shared lookback, T1, still-forming bar)
Short: on chart bars, close from the still-forming T1 bar < EMA(close, shared lookback, T1, still-forming bar)
Long: on chart bars, close from the still-forming T2 bar > EMA(close, shared lookback, T2, still-forming bar)
Short: on chart bars, close from the still-forming T2 bar < EMA(close, shared lookback, T2, still-forming bar)
Long: crossover(high, high[1]) AND close > EMA(close, shared lookback) on chart bars AND close is within a proximity parameter of the opening print or any active level AND (the MTF-requirement parameter is disabled OR close from the still-forming T1 and T2 bars is above its respective EMA(close, shared lookback, timeframe, still-forming bar) on chart bars)
Short: crossunder(low, low[1]) AND close < EMA(close, shared lookback) on chart bars AND close is within a proximity parameter of the opening print or any active level AND (the MTF-requirement parameter is disabled OR close from the still-forming T1 and T2 bars is below its respective EMA(close, shared lookback, timeframe, still-forming bar) on chart bars)
Long: during the regular session, close is within a proximity parameter of the opening print AND close on chart bars and from the still-forming T1 and T2 bars is above its respective EMA(close, shared lookback, timeframe, still-forming bar)
Short: during the regular session, close is within a proximity parameter of the opening print AND close on chart bars and from the still-forming T1 and T2 bars is below its respective EMA(close, shared lookback, timeframe, still-forming bar)
Long: close on chart bars and from the still-forming T1 and T2 bars is above its respective EMA(close, shared lookback, timeframe, still-forming bar), and at least one of these conditions was false on the previous chart bar
Short: close on chart bars and from the still-forming T1 and T2 bars is below its respective EMA(close, shared lookback, timeframe, still-forming bar), and at least one of these conditions was false on the previous chart bar
Long: previous completed T3 close < previous completed T3 open AND current still-forming T3 open > previous completed T3 open
Short: previous completed T3 close > previous completed T3 open AND current still-forming T3 open < previous completed T3 open