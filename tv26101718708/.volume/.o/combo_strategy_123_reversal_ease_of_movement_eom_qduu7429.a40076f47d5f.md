Calculation: Fast stochastic = SMA of the stochastic oscillator over the short smoothing lookback
Calculation: Slow stochastic = SMA of Fast stochastic over a longer lookback
Calculation: Reversal state = 1 when close[2] < close[1] AND close > close[1] AND Fast stochastic < Slow stochastic AND Fast stochastic > Level; -1 when close[2] > close[1] AND close < close[1] AND Fast stochastic > Slow stochastic AND Fast stochastic < Level; otherwise retain the prior state
Calculation: Ease of Movement value = 1,000,000 × (current change in half the high-low range − prior change in half the high-low range) ÷ (volume ÷ (high − low)); use 0 when high = low
Calculation: Ease of Movement state = 1 when Ease of Movement value > BuyZone; -1 when Ease of Movement value < SellZone; otherwise retain the prior state
Long: Reversal state = 1 AND Ease of Movement state = 1
Short: Reversal state = -1 AND Ease of Movement state = -1