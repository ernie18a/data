Calculation: Volume-weighted price = SUM(volume × (2 × close + high + low) / 4, averaging lookback) / SUM(volume, averaging lookback)
Calculation: Weighted range oscillator = 100 × (volume-weighted price - LLV(volume-weighted price, range lookback)) / MAX(HHV(volume-weighted price, range lookback) - LLV(volume-weighted price, range lookback), minimum price increment)
Calculation: Smoothed oscillator = LWMA(weighted range oscillator, averaging lookback)
Calculation: Signal line = LWMA(smoothed oscillator, averaging lookback)
Long: Smoothed oscillator > Signal line
Short: Smoothed oscillator <= Signal line