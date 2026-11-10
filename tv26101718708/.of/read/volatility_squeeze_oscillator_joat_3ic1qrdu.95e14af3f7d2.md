Calculation: Delta proxy = SMA(((close - low) - (high - close)) / max(high - low, a small positive constant)).
Calculation: Normalized delta = (delta proxy - lowest delta proxy over a lookback) / max(highest delta proxy over the same lookback - lowest delta proxy over the same lookback, a small positive constant).
Long: Normalized delta > upper threshold.
Short: Normalized delta < lower threshold.