Calculation: E(T) = EMA(close, L) of T bars, value one T bar before the last completed T bar, carried onto chart bars
Calculation: K = SMA(Stoch(RSI(close, R), F), Ks)
Calculation: D = SMA(K, Kd)
Calculation: ATR = ATR(A)
Long: close > E(T1) AND close > E(T2) AND close > E(T3) AND K crosses above D AND position side is flat
Short: close < E(T1) AND close < E(T2) AND close < E(T3) AND K crosses below D AND position side is flat
Exit: long, low <= entry price - S * ATR at entry bar OR high >= entry price + P * ATR at entry bar
Exit: short, high >= entry price + S * ATR at entry bar OR low <= entry price - P * ATR at entry bar