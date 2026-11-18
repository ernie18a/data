Calculation: SRSI K+D = SMA(Stochastic(RSI(close, SRSI RSI lookback), Stochastic lookback), K smoothing) + SMA(SMA(Stochastic(RSI(close, SRSI RSI lookback), Stochastic lookback), K smoothing), D smoothing)
Calculation: Line 1 = SMA(RSI(close, Line 1 RSI lookback), Line 1 SMA lookback) on T1 bars, sampled on chart bars from the current T1 bar, including its still-forming value
Calculation: Line 2 = EMA(100 * (SRSI K+D(T2) + SRSI K+D(T3) + SRSI K+D(T4) + SRSI K+D(T5)) / 800, EMA smoothing) on chart bars; each SRSI K+D is calculated on its Tn bars and sampled on chart bars from the current Tn bar, including its still-forming value
Long: Line 1 > Line 1[1] AND Line 2 > Line 2[1]
Short: Line 1 < Line 1[1] AND Line 2 < Line 2[1]