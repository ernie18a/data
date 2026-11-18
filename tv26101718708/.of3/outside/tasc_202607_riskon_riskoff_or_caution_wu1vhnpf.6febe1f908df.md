Calculation: Favorable count = (SPX close > SMA(SPX close, P1)) + (VIX close < VIX3M close) + (Z-score(HYG close / IEF close, P2) > P3)
Long: time_close = time_close(T1) AND Favorable count >= P4
Exit: long, time_close = time_close(T1) AND Favorable count < P4