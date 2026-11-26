Calculation: Trend(T) = 1 when close > EMA(close, fast lookback) AND EMA(close, fast lookback) > EMA(close, slow lookback) AND RSI(close, RSI lookback) > RSI threshold; -1 when close < EMA(close, fast lookback) AND EMA(close, fast lookback) < EMA(close, slow lookback) AND RSI(close, RSI lookback) < RSI threshold; otherwise 0, computed on T bars and mapped to chart bars using the latest available T bar, including the still-forming bar in real time
Long: Trend(T) = 1 for each T in T1, T2, T3, T4, T5
Short: Trend(T) = -1 for each T in T1, T2, T3, T4, T5
Calculation: Score = Trend(T1) + Trend(T2) + Trend(T3) + Trend(T4) + Trend(T5), mapped to chart bars
Long: Score >= bias threshold
Short: Score <= -bias threshold
Long: Score = 5 AND Score[1] != 5
Short: Score = -5 AND Score[1] != -5
Long: crossover(EMA(close, fast lookback), EMA(close, slow lookback)) on chart bars
Short: crossunder(EMA(close, fast lookback), EMA(close, slow lookback)) on chart bars