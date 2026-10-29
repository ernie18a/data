Calculation: Fish = Let midpoint be (high + low) / 2; over the lookback, find the highest high and lowest low. Normalize the midpoint as 0.66 × ((midpoint − lowest low) / (highest high − lowest low) − 0.5) + 0.67 × prior normalized value, clamped to [−0.999, 0.999]. Fish is 0.5 × ln((1 + normalized value) / (1 − normalized value)) + 0.5 × prior Fish.
Long: Fish > 0
Short: Fish < 0