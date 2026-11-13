Calculation: delta = volume * (2 * (close - low) / (high - low) - 1), and delta = 0 when high equals low
Calculation: delta_smooth = moving average of delta over a lookback of N bars
Calculation: threshold = a fixed non-negative fraction * simple moving average of volume over the same lookback N as delta_smooth
Long: delta_smooth > threshold on the current bar AND NOT (delta_smooth > threshold on the previous bar)
Short: delta_smooth < -threshold on the current bar AND NOT (delta_smooth < -threshold on the previous bar)