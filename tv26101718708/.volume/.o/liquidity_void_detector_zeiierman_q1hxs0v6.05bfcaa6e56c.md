Calculation: Volume shock z-score = z-score of ln(volume / SMA(volume, volume-baseline lookback)); undefined if volume or its SMA is nonpositive.
Calculation: 1-bar return z-score = z-score of ln(close / previous close).
Calculation: Z-score = (value − rolling mean) / rolling standard deviation; 0 when standard deviation is 0.
Calculation: Liquidity void oscillator = 1-bar return z-score × (1 if volume shock z-score ≤ low-volume threshold, otherwise non-low-volume weight).
Long: Liquidity void oscillator < lower threshold AND previous bar's oscillator ≥ lower threshold
Short: Liquidity void oscillator > upper threshold AND previous bar's oscillator ≤ upper threshold