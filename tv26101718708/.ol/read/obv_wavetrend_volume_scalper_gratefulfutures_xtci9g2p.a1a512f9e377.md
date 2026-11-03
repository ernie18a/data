Calculation: Smoothed OBV oscillator = smooth the difference between signed cumulative volume and its EMA; signed cumulative volume adds volume when the selected price source rises, subtracts volume when it falls, and adds zero when unchanged
Calculation: Squeeze Momentum = linear regression, over a lookback, of close minus the average of (the midpoint of the lookback high and low) and the lookback SMA of close
Calculation: WaveTrend 1 = EMA of the normalized deviation of HLC3 from its EMA, using the EMA of absolute deviation as the scale
Calculation: WaveTrend 2 = SMA of WaveTrend 1
Long: previous smoothed OBV oscillator < 0 AND smoothed OBV oscillator > 0 AND current Squeeze Momentum > previous Squeeze Momentum AND WaveTrend 1 > WaveTrend 2
Short: previous smoothed OBV oscillator > 0 AND smoothed OBV oscillator < 0 AND current Squeeze Momentum < previous Squeeze Momentum AND WaveTrend 1 < WaveTrend 2