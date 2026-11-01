Calculation: Volume-weighted price = sum(selected OHLC-derived price × volume) / max(sum(volume), 1) over a lookback including the current bar; weighted close is (high + low + 2 × close) / 4.
Calculation: Normalized oscillator = 100 × (volume-weighted price − its rolling minimum) / (its rolling maximum − its rolling minimum) − 50, using a separate lookback including the current bar; use −50 when the range is zero.
Calculation: First smoothed oscillator = a moving average of the normalized oscillator.
Calculation: Second smoothed oscillator = the same moving average, with the same parameters, applied to the first smoothed oscillator.
Long: First smoothed oscillator > second smoothed oscillator.
Short: First smoothed oscillator <= second smoothed oscillator.