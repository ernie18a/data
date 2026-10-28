Calculation: Volatility ratio = ATR divided by its moving average.
Calculation: Adaptive velocity lookback = rounded inverse volatility ratio scaled by a parameter, clamped to its minimum and maximum lookback.
Calculation: Adaptive volume lookback = rounded inverse volatility ratio scaled by a separate parameter, clamped to its minimum and maximum lookback.
Calculation: Signed kinetic energy = sign of rate of change over the adaptive velocity lookback × 0.5 × (volume / its moving average over the adaptive volume lookback) × (that rate of change)².
Calculation: Smoothed regime oscillator = EMA of 100 × tanh((signed kinetic energy − its moving average over the adaptive volume lookback) / its standard deviation over the adaptive volume lookback).
Long: Smoothed regime oscillator > upper threshold AND current oscillator − previous-bar oscillator > 0
Short: Smoothed regime oscillator < lower threshold AND current oscillator − previous-bar oscillator < 0