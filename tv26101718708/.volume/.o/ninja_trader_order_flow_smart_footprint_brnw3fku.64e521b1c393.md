Calculation: Delta = (close > open ? 1 : -1) × (abs(close − open) / (high − low + 0.000001)) × volume
Long: Delta > 0 AND abs(Delta) > 0.3 × volume
Short: Delta < 0 AND abs(Delta) > 0.3 × volume