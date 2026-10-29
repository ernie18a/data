Calculation: Spectrally smoothed Williams %R = calculate Williams %R from high, low, and close over a lookback on the configured indicator timeframe; apply a discrete cosine transform to a rolling window of Williams %R values, zero coefficients at and above a smoothing cutoff, then apply the inverse transform. Use completed bars.
Long: latest value > previous value AND previous value >= the value before that
Short: latest value < previous value AND previous value <= the value before that
Exit: long, latest value < previous value
Exit: short, latest value > previous value