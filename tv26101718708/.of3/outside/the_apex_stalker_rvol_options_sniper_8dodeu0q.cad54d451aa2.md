Calculation: ATR travel percentage = abs(T2 close - previous T2 close) / (ATR(T2, P3) if ATR(T2, P3) != 0 else 1) * 100
Long: T1 close > EMA(T2 close, P6)
Short: T1 close <= EMA(T2 close, P6)
Long: ((T1 close - previous T1 close) / previous T1 close) * 100 > 0
Short: ((T1 close - previous T1 close) / previous T1 close) * 100 <= 0
Long: T1 volume / (SMA(T1 volume, P1) if SMA(T1 volume, P1) != 0 else 1) >= P2 AND ((T1 close - previous T1 close) / previous T1 close) * 100 > 0 AND ATR travel percentage < P4 AND T1 close > EMA(T2 close, P6)
Short: T1 volume / (SMA(T1 volume, P1) if SMA(T1 volume, P1) != 0 else 1) >= P2 AND ATR travel percentage >= P5