Calculation: Normalized OBV oscillator = clamp(50 + 50 × (OBV − EMA(OBV, longer lookback)) / highest(abs(OBV − EMA(OBV, longer lookback)), normalization lookback), 0, 100), using the current bar; OBV cumulatively adds volume when close rises, subtracts volume when close falls, and is unchanged when close is unchanged.
Calculation: Displayed OBV oscillator = normalized OBV oscillator, optionally smoothed with an EMA using a configurable lookback.
Long: Displayed OBV oscillator >= 50
Short: Displayed OBV oscillator < 50