Calculation: LegValue(L, engine) = RSI(source, L) if engine is RSI; SMA(Stochastic %K(close, high, low, L), K smoothing) if engine is Stoch
Calculation: LegSignal(L, engine) = EMA(RSI(source, L), signal lookback) if engine is RSI; SMA(LegValue(L, engine), D smoothing) if engine is Stoch
Calculation: Consensus(X, k, engine) = 0 if X bar count < longest leg lookback + signal lookback if engine is RSI, or longest leg lookback + K smoothing + D smoothing if engine is Stoch; 1 if LegValue(L, engine) > LegSignal(L, engine) for all three L in {shortest, middle, longest leg lookback}; -1 if LegValue(L, engine) < LegSignal(L, engine) for all three L; else 0; evaluated on X bars, k bars back (0 = developing bar, 1 = last completed bar)
Calculation: UpStart(X, k, engine) = Consensus(X, k, engine) = 1 AND Consensus(X, k+1, engine) = 0; chart bars take its value from X
Calculation: DnStart(X, k, engine) = Consensus(X, k, engine) = -1 AND Consensus(X, k+1, engine) = 0; chart bars take its value from X
Long: UpStart(T1, 0, engine) AND NOT UpStart(T1, 0, engine)[1]
Long: UpStart(T1, 1, engine) AND NOT UpStart(T1, 1, engine)[1]
Short: DnStart(T1, 0, engine) AND NOT DnStart(T1, 0, engine)[1]
Short: DnStart(T1, 1, engine) AND NOT DnStart(T1, 1, engine)[1]
Long: Consensus(T1, 0, engine) = 1
Short: Consensus(T1, 0, engine) = -1
Long: Consensus(T2, 0, engine) = 1 AND T2 at or above chart timeframe
Short: Consensus(T2, 0, engine) = -1 AND T2 at or above chart timeframe
Long: Consensus(T3, 0, engine) = 1 AND T3 at or above chart timeframe
Short: Consensus(T3, 0, engine) = -1 AND T3 at or above chart timeframe
Long: Consensus(T4, 0, engine) = 1 AND T4 at or above chart timeframe
Short: Consensus(T4, 0, engine) = -1 AND T4 at or above chart timeframe
Long: Consensus(T5, 0, engine) = 1 AND T5 at or above chart timeframe
Short: Consensus(T5, 0, engine) = -1 AND T5 at or above chart timeframe
Long: Consensus(T6, 0, engine) = 1 AND T6 at or above chart timeframe
Short: Consensus(T6, 0, engine) = -1 AND T6 at or above chart timeframe
Long: Consensus(T7, 0, engine) = 1 AND T7 at or above chart timeframe
Short: Consensus(T7, 0, engine) = -1 AND T7 at or above chart timeframe
Long: Consensus(T8, 0, engine) = 1 AND T8 at or above chart timeframe
Short: Consensus(T8, 0, engine) = -1 AND T8 at or above chart timeframe