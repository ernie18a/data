Calculation: Fisher = 0.5 × ln((1 + X) / (1 − X)) + 0.5 × prior Fisher, where X = (P − rolling lowest low) / (rolling highest high − rolling lowest low) − 0.5 + 0.67 × prior X, clamped to [−999, 999]; P is the configured applied price.
Long: Fisher > its prior-bar value
Short: Fisher < its prior-bar value