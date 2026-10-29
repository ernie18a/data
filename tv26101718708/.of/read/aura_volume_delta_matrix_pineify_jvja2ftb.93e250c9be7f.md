Calculation: Volume delta = volume when close > open, −volume when close < open, and 0 when close = open
Calculation: Smoothed volume delta = EMA of volume delta
Calculation: Signal line = EMA of smoothed volume delta, using a shorter lookback than the EMA used for smoothed volume delta
Long: Smoothed volume delta > signal line AND previous smoothed volume delta ≤ previous signal line AND smoothed volume delta > 0
Short: Smoothed volume delta < signal line AND previous smoothed volume delta ≥ previous signal line AND smoothed volume delta < 0