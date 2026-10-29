Calculation: Bar volume delta = volume when close > open, −volume when close < open, otherwise 0
Calculation: Cumulative volume delta = running sum of bar volume delta
Calculation: Detrended cumulative volume delta = cumulative volume delta minus its EMA
Calculation: Divergence strength = the absolute change in detrended cumulative volume delta between successive same-side pivots divided by its recent high-to-low range, multiplied by 100 and capped at 100 (use 1 if the range is 0)
Long: confirmed swing low is below the previous confirmed swing low AND detrended cumulative volume delta at the new swing is above its value at the previous swing AND divergence strength ≥ minimum strength
Short: confirmed swing high is above the previous confirmed swing high AND detrended cumulative volume delta at the new swing is below its value at the previous swing AND divergence strength ≥ minimum strength