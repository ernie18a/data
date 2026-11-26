Calculation: Smoothed Fast Stochastic = SMA(Stochastic(close, high, low, lookback B), smoothing B)
Long: close[bar before the previous bar] < close[previous bar] AND close > close[previous bar] AND Stochastic Slow(lookback A) < level A
Short: close[bar before the previous bar] > close[previous bar] AND close < close[previous bar] AND Stochastic Fast(lookback A) > level A
Long: close[bar before the previous bar] < close[previous bar] AND close > close[previous bar] AND Smoothed Fast Stochastic < SMA(Smoothed Fast Stochastic, smoothing C) AND Smoothed Fast Stochastic > level B
Short: close[bar before the previous bar] > close[previous bar] AND close < close[previous bar] AND Smoothed Fast Stochastic > SMA(Smoothed Fast Stochastic, smoothing C) AND Smoothed Fast Stochastic < level B
Long: volume < SMA(volume, lookback D)
Short: volume > SMA(volume, lookback D)
Long: close[bar before the previous bar] < close[previous bar] AND close > close[previous bar] AND Smoothed Fast Stochastic < SMA(Smoothed Fast Stochastic, smoothing C) AND Smoothed Fast Stochastic > level B AND volume < SMA(volume, lookback D)
Short: close[bar before the previous bar] > close[previous bar] AND close < close[previous bar] AND Smoothed Fast Stochastic > SMA(Smoothed Fast Stochastic, smoothing C) AND Smoothed Fast Stochastic < level B AND volume > SMA(volume, lookback D)