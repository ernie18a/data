Calculation: Mean = EMA of close over a lookback
Calculation: MAD = average absolute difference between each close in a lookback and the current Mean
Calculation: Smoothed deviation = selected moving average of (close − Mean) / MAD, using zero when MAD is zero
Long: Smoothed deviation > 0
Short: Smoothed deviation <= 0