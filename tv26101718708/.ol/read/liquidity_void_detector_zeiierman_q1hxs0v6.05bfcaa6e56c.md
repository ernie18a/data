Calculation: Volume shock z-score = z-score of ln(volume / SMA(volume, baseline lookback)) over a volume-shock lookback
Calculation: Return z-score = z-score of ln(close / previous close) over a return lookback
Calculation: Liquidity void oscillator = return z-score × (1 if volume shock z-score ≤ low-volume threshold, otherwise the non-low-volume fade factor)
Long: Liquidity void oscillator crosses below the lower threshold (current value < threshold AND previous value ≥ threshold)
Short: Liquidity void oscillator crosses above the upper threshold (current value > threshold AND previous value ≤ threshold)