Calculation: Fast stochastic = SMA(100 × (close − lowest low over the lookback) / (highest high over the lookback − lowest low over the lookback), short smoothing lookback)
Calculation: Slow stochastic = SMA(Fast stochastic, longer smoothing lookback)
Calculation: Reversal state = initialize to 0; set to 1 when close[2] < close[1] AND close > close[1] AND Fast stochastic < Slow stochastic AND Fast stochastic > level; set to -1 when close[2] > close[1] AND close < close[1] AND Fast stochastic > Slow stochastic AND Fast stochastic < level; otherwise retain the prior state
Calculation: Ease of Movement score = 1,000,000 × (current half-range change − prior half-range change) / (volume / (high − low)), where half-range = (high − low) / 2 and half-range change = current half-range − prior half-range; score is 0 when high = low
Calculation: Ease of Movement state = initialize to 0; set to 1 when Ease of Movement score > upper threshold; set to -1 when Ease of Movement score < lower threshold; otherwise retain the prior state
Long: Reversal state = 1 AND Ease of Movement state = 1
Short: Reversal state = -1 AND Ease of Movement state = -1
Exit: long, Reversal state != 1 OR Ease of Movement state != 1
Exit: short, Reversal state != -1 OR Ease of Movement state != -1