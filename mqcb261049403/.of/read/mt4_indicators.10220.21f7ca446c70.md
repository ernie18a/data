Calculation: For each of nine strictly increasing timeframes T1 through T9, M(T) = EMA of close with a shorter lookback minus EMA of close with a longer lookback; S(T) = SMA of M(T). Use the same respective lookbacks across timeframes. Each timeframe may be lower than, equal to, or higher than the chart timeframe; use its bar still forming at the evaluation time.
Long: M(T) > S(T) for any T from T1 through T9
Short: M(T) < S(T) for any T from T1 through T9
Long: M(T1) > S(T1) AND M(T2) > S(T2)
Short: M(T1) < S(T1) AND M(T2) < S(T2)
Long: M(T3) < S(T3) AND M(T4) > S(T4) AND M(T5) > S(T5)
Long: M(T3) > S(T3) AND M(T4) > S(T4) AND M(T5) < S(T5)
Long: M(T3) > S(T3) AND M(T4) < S(T4) AND M(T5) > S(T5)
Long: M(T3) > S(T3) AND M(T4) > S(T4) AND M(T5) > S(T5) AND (M(T6) > S(T6) OR M(T6) < S(T6))
Short: M(T3) > S(T3) AND M(T4) < S(T4) AND M(T5) < S(T5)
Short: M(T3) < S(T3) AND M(T4) < S(T4) AND M(T5) > S(T5)
Short: M(T3) < S(T3) AND M(T4) > S(T4) AND M(T5) < S(T5)
Short: M(T3) < S(T3) AND M(T4) < S(T4) AND M(T5) < S(T5) AND (M(T6) > S(T6) OR M(T6) < S(T6))
Long: M(T7) > S(T7) AND (M(T6) > S(T6) OR M(T6) < S(T6))
Short: M(T7) < S(T7) AND (M(T6) > S(T6) OR M(T6) < S(T6))
Long: M(T7) > S(T7) AND (S(T5) > 0 OR S(T5) < 0) AND ((M(T6) > S(T6) AND (M(T5) > S(T5) OR M(T5) < S(T5))) OR (M(T6) < S(T6) AND (M(T5) > S(T5) OR (M(T5) < S(T5) AND S(T5) < 0))))
Short: M(T7) < S(T7) AND (S(T5) > 0 OR S(T5) < 0) AND ((M(T6) < S(T6) AND (M(T5) > S(T5) OR M(T5) < S(T5))) OR (M(T6) > S(T6) AND (M(T5) < S(T5) OR (M(T5) > S(T5) AND S(T5) > 0))))