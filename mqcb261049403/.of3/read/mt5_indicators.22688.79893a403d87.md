Calculation: Volume-adjusted oscillator = JJMA(volume * (100 * (applied price - (MA(applied price, method 1, lookback 1, phase 1) - R)) / (2 * R) - 50), smoothing lookback, smoothing phase), where R = MA(high - low, method 2, lookback 2, phase 2), using 1 when R is zero
Calculation: Smoothed volume = JJMA(volume, smoothing lookback, smoothing phase)
Long: Volume-adjusted oscillator > less-extreme upper threshold * smoothed volume AND Volume-adjusted oscillator <= more-extreme upper threshold * smoothed volume
Long: Volume-adjusted oscillator > more-extreme upper threshold * smoothed volume
Short: Volume-adjusted oscillator < less-extreme lower threshold * smoothed volume AND Volume-adjusted oscillator >= more-extreme lower threshold * smoothed volume
Short: Volume-adjusted oscillator < more-extreme lower threshold * smoothed volume