Calculation: MA(T) = the selected EMA or SMA of close over the shared lookback on T, sampled on chart bars with lookahead off from T’s current bar, which may still be forming; MA(T)[1] is the prior T-bar MA
Long: for each T in {T1, T2, T3, T4, T5, T6, T7, T8}, close(T) > MA(T) and MA(T) > MA(T)[1]
Long: for each T in {T1, T2, T3, T4, T5, T6, T7, T8}, close(T) > MA(T) and MA(T) <= MA(T)[1]
Short: for each T in {T1, T2, T3, T4, T5, T6, T7, T8}, close(T) < MA(T) and MA(T) < MA(T)[1]
Short: for each T in {T1, T2, T3, T4, T5, T6, T7, T8}, close(T) < MA(T) and MA(T) >= MA(T)[1]
Long: for every T in {T1, T2, T3, T4, T5, T6, T7, T8}, close(T) > MA(T) and MA(T) > MA(T)[1]
Long: for every T in {T1, T2, T3, T4, T5, T6, T7, T8}, close(T) > MA(T), and for at least one T, MA(T) <= MA(T)[1]
Short: for every T in {T1, T2, T3, T4, T5, T6, T7, T8}, close(T) < MA(T) and MA(T) < MA(T)[1]
Short: for every T in {T1, T2, T3, T4, T5, T6, T7, T8}, close(T) < MA(T), and for at least one T, MA(T) >= MA(T)[1]
Long: for every T in {T1, T2, T3, T4, T5, T6, T7, T8}, close(T) > MA(T) and MA(T) > MA(T)[1], and at least one T failed this condition on the prior chart bar
Long: for every T in {T1, T2, T3, T4, T5, T6, T7, T8}, close(T) > MA(T), for at least one T, MA(T) <= MA(T)[1], and at least one T had close(T) <= MA(T) on the prior chart bar
Short: for every T in {T1, T2, T3, T4, T5, T6, T7, T8}, close(T) < MA(T) and MA(T) < MA(T)[1], and at least one T failed this condition on the prior chart bar
Short: for every T in {T1, T2, T3, T4, T5, T6, T7, T8}, close(T) < MA(T), for at least one T, MA(T) >= MA(T)[1], and at least one T had close(T) >= MA(T) on the prior chart bar