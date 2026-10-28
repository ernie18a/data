Calculation: Fast stochastic = SMA(100 × (close − lowest low over the lookback) ÷ (highest high over the lookback − lowest low over the lookback)), using the short smoothing lookback
Calculation: Slow stochastic = SMA(Fast stochastic, using the longer smoothing lookback)
Calculation: Reversal state = 1 when close[2] < close[1] AND close > close[1] AND Fast stochastic < Slow stochastic AND Fast stochastic > level; −1 when close[2] > close[1] AND close < close[1] AND Fast stochastic > Slow stochastic AND Fast stochastic < level; otherwise retain the previous state (initially 0)
Calculation: Volume state = −1 when volume > SMA(volume, lookback); 1 when volume < SMA(volume, lookback); otherwise retain the previous state (initially 0)
Long: Reversal state = 1 AND Volume state = 1
Short: Reversal state = −1 AND Volume state = −1
Exit: long, Reversal state != 1 OR Volume state != 1
Exit: short, Reversal state != −1 OR Volume state != −1