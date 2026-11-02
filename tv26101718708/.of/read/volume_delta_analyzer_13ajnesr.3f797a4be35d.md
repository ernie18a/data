Calculation: Volume ratio = volume / SMA(volume) when SMA(volume) > 0; otherwise 1.
Calculation: Body ratio = abs(close - open) / (high - low) when high > low; otherwise 1.
Long: Volume ratio >= volume multiplier AND body ratio <= maximum body ratio AND close >= high - (high - low) * upper-range fraction, with the delta-absorption requirement disabled.
Short: Volume ratio >= volume multiplier AND body ratio <= maximum body ratio AND close <= low + (high - low) * lower-range fraction, with the delta-absorption requirement disabled.