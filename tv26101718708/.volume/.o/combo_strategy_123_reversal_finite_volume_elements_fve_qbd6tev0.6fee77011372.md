Calculation: Fast stochastic = SMA of 100 × (close − lowest low) / (highest high − lowest low); Slow stochastic = SMA of Fast stochastic over a longer smoothing lookback
Calculation: Reversal state = +1 when close[2] < close[1], close > close[1], Fast stochastic < Slow stochastic, and Fast stochastic > the threshold; −1 when close[2] > close[1], close < close[1], Fast stochastic > Slow stochastic, and Fast stochastic < the threshold; otherwise retain the prior state (initially 0)
Calculation: Signed volume = volume when close − hl2 + hlc3 − hlc3[1] > Factor × close / 100; −volume when that expression < −Factor × close / 100; otherwise 0. FVE = prior FVE + ((Signed volume / SMA(volume, lookback)) / lookback) × 100, initially 0
Calculation: FVE state = +1 when FVE > FVE[1] and FVE > FVE[2]; −1 when FVE < FVE[1] and FVE < FVE[2]; otherwise retain the prior state (initially 0)
Long: Reversal state = 1 AND FVE state = 1
Short: Reversal state = −1 AND FVE state = −1