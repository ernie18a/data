Calculation: Upside breakout = high > close[1] + TR[1] AND close > open
Calculation: Downside breakout = low < close[1] - TR[1] AND close < open
Long: rising(EMA(close, shorter EMA lookback), direction lookback) OR rising(EMA(close, longer EMA lookback), direction lookback)
Short: falling(EMA(close, shorter EMA lookback), direction lookback) OR falling(EMA(close, longer EMA lookback), direction lookback)
Long: Upside breakout AND time >= entry start time AND time < entry end time
Short: Downside breakout AND time >= entry start time AND time < entry end time
Exit: long, (Downside breakout AND (time < entry start time OR time >= entry end time)) OR crossunder(close(T1, still-forming bar), open(T1, still-forming bar)) on chart bars using T1 values OR low <= entry price - stop-loss distance
Exit: short, (Upside breakout AND (time < entry start time OR time >= entry end time)) OR crossover(close(T1, still-forming bar), open(T1, still-forming bar)) on chart bars using T1 values OR high >= entry price + stop-loss distance