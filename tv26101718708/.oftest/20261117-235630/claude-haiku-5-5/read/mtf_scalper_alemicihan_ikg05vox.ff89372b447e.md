Calculation: ema_T1 = EMA(close, L, T1, last completed bar)[1]
Calculation: ema_T2 = EMA(close, L, T2, last completed bar)[1]
Calculation: ema_T3 = EMA(close, L, T3, last completed bar)[1]
Calculation: stoch_k = SMA(StochRSI(close, R, F), K)
Calculation: stoch_d = SMA(stoch_k, D)
Calculation: atr = ATR(A)
Long: position side is flat AND close > ema_T1 AND close > ema_T2 AND close > ema_T3 AND stoch_k crosses above stoch_d
Short: position side is flat AND close < ema_T1 AND close < ema_T2 AND close < ema_T3 AND stoch_k crosses below stoch_d
Exit: long, low <= entry price - SL * atr at entry
Exit: long, high >= entry price + TP * atr at entry
Exit: short, high >= entry price + SL * atr at entry
Exit: short, low <= entry price - TP * atr at entry