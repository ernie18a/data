Calculation: Estimated delta = volume × ((close − low) − (high − close)) / (high − low); use 0 when high = low
Calculation: Delta ratio = estimated delta / volume; use 0 when volume = 0
Calculation: Cumulative delta = running sum of estimated delta, reset when the weekday changes or at 08:30:00; use the cumulative delta from the pivot bar for divergence comparisons
Calculation: Confirmed pivot low/high = a low/high strictly below/above the surrounding bars on both sides, using the same number of bars on each side; that number is max(3, divergence lookback / 5), rounded down
Calculation: Smoothed delta Z-score = EMA of (estimated delta − its rolling mean) / its rolling standard deviation; use the normalization lookback for the mean and standard deviation and the delta smoothing lookback for the EMA; use 0 when standard deviation is 0
Long: Delta ratio > imbalance threshold
Long: On a confirmed pivot low, the pivot low is lower than the previous confirmed pivot low AND cumulative delta at the pivot is higher than at the previous confirmed pivot low
Long: Smoothed delta Z-score crosses above 1.5
Short: Delta ratio < −imbalance threshold
Short: On a confirmed pivot high, the pivot high is higher than the previous confirmed pivot high AND cumulative delta at the pivot is lower than at the previous confirmed pivot high
Short: Smoothed delta Z-score crosses below −1.5