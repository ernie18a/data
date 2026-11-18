Long: close > close[n] > close[n+1] AND Slow Stochastic(close, high, low, comment stochastic lookback, T1, current bar) < level (on T1 bars)
Short: close < close[n] < close[n+1] AND Fast Stochastic(close, high, low, comment stochastic lookback, T1, current bar) > level (on T1 bars)
Calculation: Reversal fast value = SMA(Stochastic(close, high, low, reversal lookback), shorter smoothing lookback)
Calculation: Reversal slow value = SMA(Reversal fast value, longer smoothing lookback)
Calculation: Reversal signal = 1 when close[n+1] < close[n] AND close > close[n] AND Reversal fast value < Reversal slow value AND Reversal fast value > level; -1 when close[n+1] > close[n] AND close < close[n] AND Reversal fast value > Reversal slow value AND Reversal fast value < level; otherwise previous value, initially 0
Calculation: Volume-weighted EMA ratio = EMA(volume * close, volume lookback) / EMA(volume, same lookback)
Calculation: Volume-weighted EMA signal = 1 when Volume-weighted EMA ratio < close[n]; -1 when Volume-weighted EMA ratio > close[n]; otherwise previous value, initially 0
Calculation: Combined signal = 1 when Reversal signal = 1 AND Volume-weighted EMA signal = 1; -1 when Reversal signal = -1 AND Volume-weighted EMA signal = -1; otherwise 0
Long: (direction inversion is off AND Combined signal = 1) OR (direction inversion is on AND Combined signal = -1)
Short: (direction inversion is off AND Combined signal = -1) OR (direction inversion is on AND Combined signal = 1)
Exit: long, Combined signal = 0
Exit: short, Combined signal = 0