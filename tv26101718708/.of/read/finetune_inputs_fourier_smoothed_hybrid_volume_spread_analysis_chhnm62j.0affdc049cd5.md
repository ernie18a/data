Calculation: Fourier-smoothed price = double Fourier transform of the price series
Calculation: Volume factor = volume divided by the Fourier-smoothed volume
Calculation: Volume-adjusted spread = (shorter-lookback EMA of Fourier-smoothed close − shorter-lookback EMA of Fourier-smoothed open) × volume factor
Calculation: Smoothed spread = longer-lookback EMA of volume-adjusted spread
Long: Smoothed spread > 0 AND Volume-adjusted spread > 0
Short: Smoothed spread < 0 AND Volume-adjusted spread < 0
Exit: long or short, (Smoothed spread ≤ 0 OR Volume-adjusted spread ≤ 0) AND (Smoothed spread ≥ 0 OR Volume-adjusted spread ≥ 0)