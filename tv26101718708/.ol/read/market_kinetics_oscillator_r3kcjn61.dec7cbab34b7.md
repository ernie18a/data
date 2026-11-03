Calculation: Speed = EMA of current activity-per-second divided by its long-lookback SMA; activity is volume per bar-second or one tick per bar-second.
Calculation: Price velocity = Z-score of the current close change divided by ATR, using a long-lookback mean and standard deviation.
Calculation: Acceleration = Z-score of the EMA of the one-bar change in Speed, using a long-lookback mean and standard deviation.
Calculation: Jerk = Z-score of the EMA of the one-bar change in Acceleration before normalization, using a long-lookback mean and standard deviation.
Calculation: Impulse = sum of normalized Acceleration over a lookback period.
Long: Price velocity >= 3 OR Acceleration >= 3 OR Jerk >= 3 OR Impulse >= 3
Short: Price velocity <= -3 OR Acceleration <= -3 OR Jerk <= -3 OR Impulse <= -3