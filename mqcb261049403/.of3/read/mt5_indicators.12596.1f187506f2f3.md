Calculation: normalized oscillator = 100 * (SMA(close, input averaging lookback) - lowest(SMA(close, input averaging lookback), extrema lookback)) / max(highest(SMA(close, input averaging lookback), extrema lookback) - lowest(SMA(close, input averaging lookback), extrema lookback), minimum price increment) - 50
Calculation: first smoothed oscillator = selected smoothing method(normalized oscillator, smoothing lookback, smoothing phase)
Calculation: second smoothed oscillator = selected smoothing method(first smoothed oscillator, smoothing lookback, smoothing phase)
Long: first smoothed oscillator > second smoothed oscillator
Short: first smoothed oscillator <= second smoothed oscillator