Calculation: Straddle premium(T) = call option close(T) + put option close(T), treating a missing close as zero
Long: At each of T1, T2, T3, T4, T5, and T6, straddle premium(T) > SMA(straddle premium(T), P1)
Short: At each of T1, T2, T3, T4, T5, and T6, straddle premium(T) <= SMA(straddle premium(T), P1)
Long: At each of T1, T2, T3, T4, T5, and T6, straddle premium(T) > SMA(straddle premium(T), P2)
Short: At each of T1, T2, T3, T4, T5, and T6, straddle premium(T) <= SMA(straddle premium(T), P2)
Long: At each of T1, T2, T3, T4, T5, and T6, straddle premium(T) > SMA(straddle premium(T), P3)
Short: At each of T1, T2, T3, T4, T5, and T6, straddle premium(T) <= SMA(straddle premium(T), P3)
Long: At each of T1, T2, T3, T4, T5, and T6, straddle premium(T) > SMA(straddle premium(T), P4)
Short: At each of T1, T2, T3, T4, T5, and T6, straddle premium(T) <= SMA(straddle premium(T), P4)
Long: At each of T1, T2, T3, T4, T5, and T6, straddle premium(T) > SMA(straddle premium(T), P5)
Short: At each of T1, T2, T3, T4, T5, and T6, straddle premium(T) <= SMA(straddle premium(T), P5)
Long: At each of T1, T2, T3, T4, T5, and T6, RSI(straddle premium(T), P6) > P7
Short: At each of T1, T2, T3, T4, T5, and T6, RSI(straddle premium(T), P6) < P7
Long: At each of T1, T2, T3, T4, T5, and T6, MACD histogram(straddle premium(T), P8, P9, P10) > 0
Short: At each of T1, T2, T3, T4, T5, and T6, MACD histogram(straddle premium(T), P8, P9, P10) < 0
Calculation: Custom SuperTrend direction(T) = initialize bearish; each bar set raw upper/lower bands to straddle premium(T) plus/minus P12 times RMA(abs(straddle premium(T) - prior straddle premium(T)), P11); ratchet upper to the lower of raw upper and prior upper, or raw upper if prior upper is missing, and lower to the higher of raw lower and prior lower, or raw lower if prior lower is missing; when bearish, flip bullish if straddle premium(T) > ratcheted upper and reset lower to raw lower; when bullish, flip bearish if straddle premium(T) < ratcheted lower and reset upper to raw upper; otherwise retain direction
Long: At each of T1, T2, T3, T4, T5, and T6, Custom SuperTrend direction(T) = bullish
Short: At each of T1, T2, T3, T4, T5, and T6, Custom SuperTrend direction(T) = bearish