Calculation: Volume-weighted mean = sum(close × volume) over the lookback bars divided by sum(volume) over those bars, including the current bar.
Calculation: Volume-weighted standard deviation = square root of sum(volume × (close − volume-weighted mean)²) divided by ((number of bars with nonzero volume − 1) × sum(volume) / number of bars with nonzero volume), using the same lookback bars.
Long: low ≤ volume-weighted mean − 2 × volume-weighted standard deviation
Short: high ≥ volume-weighted mean + 2 × volume-weighted standard deviation
Exit: Long, low ≤ entry price × (1 − stop-loss percentage) OR high ≥ entry price × (1 + take-profit percentage)
Exit: Short, high ≥ entry price × (1 + stop-loss percentage) OR low ≤ entry price × (1 − take-profit percentage)