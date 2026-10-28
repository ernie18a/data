Calculation: Volume-weighted mean price = sum(close × volume) / sum(volume) over the most recent lookback bars, recalculated every profile interval and held between recalculations.
Calculation: Volume-weighted mean absolute deviation = volume-weighted average of the absolute distance from the volume-weighted mean price over the same bars, recalculated and held with it.
Calculation: Oscillator = EMA over a short smoothing period of 50 + sensitivity × 25 × (close − volume-weighted mean price) / volume-weighted mean absolute deviation.
Calculation: Adaptive midline = longer-period SMA of the oscillator.
Calculation: Fast signal = shorter-period EMA of the oscillator; slow signal = longer-period EMA of the oscillator.
Long: Oscillator > adaptive midline OR fast signal > slow signal
Short: (oscillator ≤ adaptive midline AND fast signal ≤ slow signal) OR (oscillator < adaptive midline AND previous oscillator ≥ previous adaptive midline)