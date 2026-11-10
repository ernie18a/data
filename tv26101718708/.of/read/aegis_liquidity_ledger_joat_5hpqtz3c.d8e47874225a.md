Calculation: Smoothed pressure = EMA of the average of four close-price rate-of-change series, using fast, medium, slow, and macro lookbacks from shortest to longest.
Calculation: Expansion threshold = the greater of the rolling standard deviation of smoothed pressure and the minimum price increment, multiplied by a positive threshold multiplier.
Long: Smoothed pressure >= 0
Short: Smoothed pressure < 0
Long: Smoothed pressure > expansion threshold AND previous smoothed pressure <= previous expansion threshold
Short: Smoothed pressure < -expansion threshold AND previous smoothed pressure >= -previous expansion threshold
Long: Smoothed pressure > 0 AND previous smoothed pressure <= 0
Short: Smoothed pressure < 0 AND previous smoothed pressure >= 0