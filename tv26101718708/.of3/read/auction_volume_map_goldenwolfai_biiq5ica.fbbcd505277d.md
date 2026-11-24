Calculation: Pressure Delta = sum over the lookback, including the current chart bar, of nz(volume, 0) × clamp(pressure lower bound, pressure upper bound, close-location weight × (2 × ((close − low) / (high − low) if high > low else midpoint) − 1) + body-impulse weight × ((close − open) / (high − low) if high > low else 0))
Long: Pressure Delta > 0
Short: Pressure Delta < 0