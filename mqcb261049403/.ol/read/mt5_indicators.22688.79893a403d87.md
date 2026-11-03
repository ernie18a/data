Calculation: KlPrice = 100 * (price - (smoothed price - smoothed bar range)) / (2 * smoothed bar range) - 50, where price is the close and bar range is high minus low
Calculation: Volume-adjusted oscillator = JMA(KlPrice * volume)
Calculation: Smoothed volume = JMA(volume)
Long: Volume-adjusted oscillator < oversold level 1 * smoothed volume OR volume-adjusted oscillator < oversold level 2 * smoothed volume
Short: Volume-adjusted oscillator > overbought level 1 * smoothed volume OR volume-adjusted oscillator > overbought level 2 * smoothed volume