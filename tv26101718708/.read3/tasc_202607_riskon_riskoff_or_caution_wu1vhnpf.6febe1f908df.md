Calculation: Favorable count = (SPX close on T1 last completed bar > SMA(SPX close, trend lookback, T1, last completed bar)) + (VIX close on T1 last completed bar / VIX3M close on T1 last completed bar < volatility-ratio threshold) + (Z-score(HYG close on T1 last completed bar / IEF close on T1 last completed bar, credit lookback, T1, last completed bar) > credit-score threshold)
Long: Favorable count >= minimum favorable-count threshold
Exit: long, Favorable count < minimum favorable-count threshold
Calculation: Favorable count = (SPX close > SMA(SPX close, P1)) + (VIX close < VIX3M close) + (Z-score(HYG close / IEF close, P2) > P3)
Long: time_close = time_close(T1) AND Favorable count >= P4
Exit: long, time_close = time_close(T1) AND Favorable count < P4