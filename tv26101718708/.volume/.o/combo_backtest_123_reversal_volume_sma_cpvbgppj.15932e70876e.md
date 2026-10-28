Calculation: Fast stochastic = 100 × (close − lowest low over lookback) ÷ (highest high over lookback − lowest low over lookback), smoothed with a short-lookback SMA
Calculation: Slow stochastic = SMA(fast stochastic, a longer smoothing lookback than the one used for fast stochastic)
Calculation: Volume average = SMA(volume, lookback)
Long: close[2] < close[1] AND close > close[1] AND fast stochastic < slow stochastic AND fast stochastic > threshold AND volume < volume average
Short: close[2] > close[1] AND close < close[1] AND fast stochastic > slow stochastic AND fast stochastic < threshold AND volume > volume average