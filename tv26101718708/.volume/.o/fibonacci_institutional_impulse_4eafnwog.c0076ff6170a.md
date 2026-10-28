Calculation: Lower band = VWMA(hlc3, lookback) − 0.5 × multiplier × standard deviation(hlc3, lookback)
Calculation: Upper band = VWMA(hlc3, lookback) + 0.5 × multiplier × standard deviation(hlc3, lookback)
Calculation: Both bands use the same lookback and multiplier.
Long: Current hlc3 > current lower band AND previous hlc3 ≤ previous lower band
Short: Current hlc3 > current upper band AND previous hlc3 ≤ previous upper band