Calculation: Volume-weighted mean = sum(close × volume) over the lookback bars / sum(volume) over those bars
Calculation: Volume-weighted sample standard deviation = sqrt(sum(volume × (close − volume-weighted mean)^2) / ((N − 1) × sum(volume) / N)), where N is the number of bars with nonzero volume in the lookback
Calculation: Lower band = volume-weighted mean − 2 × volume-weighted sample standard deviation
Calculation: Upper band = volume-weighted mean + 2 × volume-weighted sample standard deviation
Long: low ≤ Lower band
Short: high ≥ Upper band
Exit: long, low ≤ entry price × (1 − stop-loss fraction) OR high ≥ entry price × (1 + take-profit fraction)
Exit: short, high ≥ entry price × (1 + stop-loss fraction) OR low ≤ entry price × (1 − take-profit fraction)