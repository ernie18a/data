Calculation: Adjusted close and open = close and open, optionally Fourier-transformed
Calculation: Relative volume = current volume divided by either previous-bar volume or a dynamically EMA-smoothed Fourier approximation of volume, seeded with previous-bar volume
Calculation: Volume-weighted spread = (short-lookback EMA(adjusted close) − short-lookback EMA(adjusted open)) × relative volume
Calculation: Spread trend = longer-lookback EMA(volume-weighted spread)
Long: volume-weighted spread > 0 AND spread trend > 0
Short: volume-weighted spread < 0 AND spread trend < 0
Exit: long, close-all is enabled AND NOT (volume-weighted spread > 0 AND spread trend > 0) AND NOT (volume-weighted spread < 0 AND spread trend < 0)
Exit: short, close-all is enabled AND NOT (volume-weighted spread > 0 AND spread trend > 0) AND NOT (volume-weighted spread < 0 AND spread trend < 0)