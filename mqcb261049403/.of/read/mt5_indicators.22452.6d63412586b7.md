Calculation: Volume-weighted oscillator = a selected moving average of (Williams %R + 50) multiplied by bar volume, using the same moving-average method and parameters on every bar.
Calculation: Oscillator direction = the sign of the most recent nonzero change in the volume-weighted oscillator; retain the previous direction when the oscillator is unchanged, and initialize direction as positive.
Long: Oscillator direction > 0
Short: Oscillator direction < 0