Calculation: Fast stochastic = SMA(Stochastic(close, high, low, stochastic lookback), fast smoothing lookback)
Calculation: Slow stochastic = SMA(Fast stochastic, slow smoothing lookback)
Calculation: Reversal state = 1 when close[2] < close[1] AND close > close[1] AND Fast stochastic < Slow stochastic AND Fast stochastic > threshold; -1 when close[2] > close[1] AND close < close[1] AND Fast stochastic > Slow stochastic AND Fast stochastic < threshold; otherwise its previous value, initially 0
Calculation: Average volume = SMA(volume, volume lookback)
Calculation: Volume state = -1 when volume > Average volume; 1 when volume < Average volume; otherwise its previous value, initially 0
Calculation: Combined signal = 1 when Reversal state = 1 AND Volume state = 1; -1 when Reversal state = -1 AND Volume state = -1; otherwise 0
Long: (Combined signal = 1 AND reverse mode is off) OR (Combined signal = -1 AND reverse mode is on)
Short: (Combined signal = -1 AND reverse mode is off) OR (Combined signal = 1 AND reverse mode is on)
Exit: long, Combined signal = 0
Exit: short, Combined signal = 0