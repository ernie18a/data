Calculation: EMA(P1) = EMA(monitored pair close, P1)
Calculation: EMA(P2) = EMA(monitored pair close, P2)
Calculation: EMA(P3) = EMA(monitored pair close, P3)
Calculation: EMA(P4) = EMA(monitored pair close, P4)
Calculation: Supertrend direction = direction of Supertrend(monitored pair high, monitored pair low, monitored pair close, P6, P5)
Calculation: Smoothed Stochastic %K = SMA(Stochastic %K(monitored pair close, monitored pair high, monitored pair low, P7), P8)
Calculation: Stochastic %D = SMA(Smoothed Stochastic %K, P9)
Long: EMA(P1) > EMA(P2) AND EMA(P3) > EMA(P4) AND Supertrend direction bullish AND Smoothed Stochastic %K crosses above Stochastic %D
Short: EMA(P1) < EMA(P2) AND EMA(P3) < EMA(P4) AND Supertrend direction bearish AND Smoothed Stochastic %K crosses below Stochastic %D