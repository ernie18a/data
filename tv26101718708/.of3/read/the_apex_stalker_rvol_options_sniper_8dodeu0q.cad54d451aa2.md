Calculation: RVOL = volume of the current (possibly forming) T1 bar, sampled at chart-bar close, divided by SMA(volume, volume lookback, T1 current bar, sampled at chart-bar close), replacing a zero SMA with 1
Calculation: Price change percentage = (close of current T1 bar − close of previous T1 bar) / close of previous T1 bar × 100, sampled at chart-bar close
Calculation: ATR travel percentage = abs(close of current T2 bar − close of previous T2 bar) / ATR(ATR lookback, T2 current bar), replacing a zero ATR with 1, × 100; sampled at chart-bar close
Long: RVOL ≥ RVOL threshold AND Price change percentage > 0 AND ATR travel percentage < ATR warning threshold AND close of current T1 bar > EMA(close, EMA lookback, T2 current bar)
Short: RVOL ≥ RVOL threshold AND ATR travel percentage ≥ ATR exhaustion threshold
Calculation: ATR travel percentage = abs(T2 close - previous T2 close) / (ATR(T2, P3) if ATR(T2, P3) != 0 else 1) * 100
Long: T1 close > EMA(T2 close, P6)
Short: T1 close <= EMA(T2 close, P6)
Long: ((T1 close - previous T1 close) / previous T1 close) * 100 > 0
Short: ((T1 close - previous T1 close) / previous T1 close) * 100 <= 0
Long: T1 volume / (SMA(T1 volume, P1) if SMA(T1 volume, P1) != 0 else 1) >= P2 AND ((T1 close - previous T1 close) / previous T1 close) * 100 > 0 AND ATR travel percentage < P4 AND T1 close > EMA(T2 close, P6)
Short: T1 volume / (SMA(T1 volume, P1) if SMA(T1 volume, P1) != 0 else 1) >= P2 AND ATR travel percentage >= P5