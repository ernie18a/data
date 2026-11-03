Calculation: Fast stochastic = SMA(100 × (close − lowest low over lookback N) / (highest high over lookback N − lowest low over lookback N), short smoothing length)
Calculation: Slow stochastic = SMA(fast stochastic, longer smoothing length)
Calculation: Daily pivot = (previous completed daily high + previous completed daily low + previous completed daily close) / 3
Calculation: Daily R1 = 2 × daily pivot − previous completed daily low
Calculation: Daily S1 = 2 × daily pivot − previous completed daily high
Long: close[2] < close[1] AND close > close[1] AND fast stochastic < slow stochastic AND fast stochastic > threshold AND (close > daily R1 OR (close <= daily R1 AND close >= daily S1 AND previous DPP state is long))
Short: close[2] > close[1] AND close < close[1] AND fast stochastic > slow stochastic AND fast stochastic < threshold AND (close < daily S1 OR (close <= daily R1 AND close >= daily S1 AND previous DPP state is short))