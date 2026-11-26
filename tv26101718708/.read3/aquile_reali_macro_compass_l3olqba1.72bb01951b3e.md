Calculation: Chg(x, T, B) = x - x[N], where x is the value on the last completed bar of T and [N] counts bars of B
Calculation: Dir(T, B) = IF Chg(real-yield proxy close, T, B) > 0 AND Chg(dollar index close, T, B) < 0 THEN 1 ELSE IF Chg(real-yield proxy close, T, B) < 0 AND Chg(dollar index close, T, B) > 0 THEN -1 ELSE 0
Calculation: Bias = IF chart timeframe is not intraday OR bar datetime is within the real-yield proxy's regular trading hours THEN Dir(T1, chart bars) ELSE Bias[1]
Calculation: TwoYearMove = 100 * (two-year yield close - two-year yield close[1]), on chart bars, where the yield is the value of the last completed bar of T1
Calculation: YieldSpike = ABS(TwoYearMove) >= spikeBp OR (ABS(TwoYearMove) / StandardDeviation(TwoYearMove, M) >= spikeMult AND ABS(TwoYearMove) >= spikeMin)
Long: Bias == 1
Short: Bias == -1
Exit: long, Bias == 0
Exit: short, Bias == 0
Long: Bias == 1 AND Bias[1] != 1 AND (filter disabled OR Dir(T3, T3 bars) == 1)
Short: Bias == -1 AND Bias[1] != -1 AND (filter disabled OR Dir(T3, T3 bars) == -1)
Long: filter enabled AND Dir(T3, T3 bars) == 1 AND Dir(T3, T3 bars)[1] != 1
Short: filter enabled AND Dir(T3, T3 bars) == -1 AND Dir(T3, T3 bars)[1] != -1
Long: YieldSpike AND TwoYearMove < 0
Short: YieldSpike AND TwoYearMove > 0
Long: Dir(T2, T2 bars) == 1
Short: Dir(T2, T2 bars) == -1