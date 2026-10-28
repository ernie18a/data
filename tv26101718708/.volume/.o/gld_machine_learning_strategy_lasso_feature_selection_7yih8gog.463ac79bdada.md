Calculation: Volume feature = simple moving average of volume
Calculation: Open-close feature = simple moving average of open minus close
Calculation: High-low-close feature = simple moving average of (high minus close) × (low minus close)
Calculation: Open-close-volume feature = simple moving average of open minus close × simple moving average of volume
Calculation: Low-close-volume feature = simple moving average of low minus close × simple moving average of volume
Calculation: Score = weighted sum of the normalized features
Long: Score ≥ threshold
Exit: long, Score < threshold