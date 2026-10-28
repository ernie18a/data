Calculation: Smoothed OBV oscillator = smooth the difference between cumulative signed volume and its EMA; add volume when the selected source rises, subtract volume when it falls, and add zero when unchanged
Calculation: Squeeze Momentum = linear regression of close minus the average of (highest high and lowest low midpoint) and the close SMA, over the same lookback, with offset zero
Calculation: WaveTrend 1 = EMA of ((HLC3 − EMA(HLC3, channel length)) / (0.015 × EMA(abs(HLC3 − EMA(HLC3, channel length)), channel length))), using the average length
Calculation: WaveTrend 2 = SMA of WaveTrend 1
Long: previous Smoothed OBV oscillator < 0 AND current Smoothed OBV oscillator > 0 AND current Squeeze Momentum > previous Squeeze Momentum AND WaveTrend 1 > WaveTrend 2
Short: previous Smoothed OBV oscillator > 0 AND current Smoothed OBV oscillator < 0 AND current Squeeze Momentum < previous Squeeze Momentum AND WaveTrend 1 < WaveTrend 2