Calculation: Smoothed Hull trend oscillator = Smooth(2*Smooth(selected price, floor(lookback/2), method, phase) - Smooth(selected price, lookback, method, phase) - Smooth(2*Smooth(selected price, floor(lookback/2), method, phase) - Smooth(selected price, lookback, method, phase), floor(sqrt(lookback)), method, phase), output smoothing lookback, output smoothing method, output smoothing phase) / minimum price increment
Long: Smoothed Hull trend oscillator > 0
Short: Smoothed Hull trend oscillator < 0
Long: Smoothed Hull trend oscillator on T1 bars, read on each chart bar from T1's bar still forming > 0
Short: Smoothed Hull trend oscillator on T1 bars, read on each chart bar from T1's bar still forming < 0