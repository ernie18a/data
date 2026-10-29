Calculation: Volume-weighted mean price = sum(close × volume) / sum(volume) over the profile lookback.
Calculation: Volume-weighted mean absolute deviation = sum(volume × abs(close − volume-weighted mean price)) / sum(volume) over the profile lookback.
Calculation: Volume-profile oscillator = EMA of the raw oscillator; in mean-reversion mode, raw oscillator increases with close relative to the volume-weighted mean price, scaled by the volume-weighted mean absolute deviation and sensitivity; in standard mode, raw oscillator is smoothed volume normalized to its lookback minimum and maximum.
Calculation: Adaptive midline = SMA of the oscillator over a longer lookback; when adaptive midline is disabled, it is fixed at the midpoint.
Calculation: Fast and slow signals = EMAs of the oscillator, with the fast signal using a shorter lookback than the slow signal.
Long: Volume-profile oscillator > adaptive midline OR fast signal > slow signal
Short: Volume-profile oscillator ≤ adaptive midline AND fast signal ≤ slow signal