Calculation: Trend(T) = 1 when close > EMA(close, fast lookback) AND EMA(close, fast lookback) > EMA(close, slow lookback); -1 when close < EMA(close, fast lookback) AND EMA(close, fast lookback) < EMA(close, slow lookback); otherwise 0, evaluated on T bars and sampled on chart bars using either the forming T bar or its last completed bar
Long: Trend(T1) = 1 OR Trend(T2) = 1 OR Trend(T3) = 1 OR Trend(T4) = 1 OR Trend(T5) = 1
Short: Trend(T1) = -1 OR Trend(T2) = -1 OR Trend(T3) = -1 OR Trend(T4) = -1 OR Trend(T5) = -1
Long: Trend(T) = 1 AND bars since Trend(T) changed < flip lookback, for each T1 through T5
Short: Trend(T) = -1 AND bars since Trend(T) changed < flip lookback, for each T1 through T5
Long: count of Trend(T1..T5) = 1 >= agreement threshold AND count of Trend(T1..T5) = 1 > count of Trend(T1..T5) = -1
Short: count of Trend(T1..T5) = -1 >= agreement threshold AND count of Trend(T1..T5) = -1 > count of Trend(T1..T5) = 1
Long: Trend(T1) = 1 AND Trend(T2) = 1 AND Trend(T3) = 1 AND Trend(T4) = 1 AND Trend(T5) = 1 AND NOT (all five Trend values were 1 on the previous chart bar)
Short: Trend(T1) = -1 AND Trend(T2) = -1 AND Trend(T3) = -1 AND Trend(T4) = -1 AND Trend(T5) = -1 AND NOT (all five Trend values were -1 on the previous chart bar)