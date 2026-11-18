Calculation: Momentum = EMA(EMA(close, shorter lookback) - EMA(close, longer lookback), momentum smoothing)
Long: Momentum > Momentum[1]
Short: Momentum <= Momentum[1]
Long: Momentum(T1 bars, bar still forming, sampled on chart bars) - EMA(Momentum(T1 bars, bar still forming), signal lookback) >= 0
Short: Momentum(T1 bars, bar still forming, sampled on chart bars) - EMA(Momentum(T1 bars, bar still forming), signal lookback) < 0