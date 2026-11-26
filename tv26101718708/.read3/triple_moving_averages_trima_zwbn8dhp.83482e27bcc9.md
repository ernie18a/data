Calculation: M1 = selected SMA, WMA, HMA, VWMA, or RMA(source1, lookback1), or SWMA(source1), calculated on T1 bars and mapped to chart bars with lookahead off; historical values use completed T1 bars and realtime values can use the forming T1 bar
Calculation: M2 = selected SMA, WMA, HMA, VWMA, or RMA(source2, lookback2), or SWMA(source2), calculated on T2 bars and mapped to chart bars with lookahead off; historical values use completed T2 bars and realtime values can use the forming T2 bar
Calculation: M3 = selected SMA, WMA, HMA, VWMA, or RMA(source3, lookback3), or SWMA(source3), calculated on T3 bars and mapped to chart bars with lookahead off; historical values use completed T3 bars and realtime values can use the forming T3 bar
Long: M1[p] >= M1[p+1]
Short: M1[p] < M1[p+1]
Long: M2[p+q] >= M2[p+q+1]
Short: M2[p+q] < M2[p+q+1]
Long: M3[p+2q] >= M3[p+2q+1]
Short: M3[p+2q] < M3[p+2q+1]