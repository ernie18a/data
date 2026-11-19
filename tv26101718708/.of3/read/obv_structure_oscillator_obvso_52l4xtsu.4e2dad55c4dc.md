Calculation: raw OBV oscillator = OBV(close, volume) - EMA(OBV(close, volume), OBV lookback)
Calculation: normalized OBV oscillator = optionally EMA(clamp(50 + 50 * raw OBV oscillator / highest(abs(raw OBV oscillator), normalization lookback), 0, 100), smoothing lookback), using 50 before optional smoothing when the denominator is 0
Long: normalized OBV oscillator >= 50
Short: normalized OBV oscillator < 50