Calculation: Smoothed price zone oscillator = adaptively smooth 100 × EMA(sign(close − previous close) × close) / EMA(close), where sign is 1 for a rise, −1 for a fall, and 0 for no change; both EMAs use the same lookback.
Calculation: Floating upper and lower levels = rolling minimum of the oscillator + the respective percentage of the difference between its rolling maximum and minimum.
Long: Smoothed price zone oscillator > floating upper level
Short: Smoothed price zone oscillator < floating lower level