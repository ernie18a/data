Calculation: balance flow = if high = low then 50 else if close = high then 100 else clamp(50 × (close − low) / (high − close), 0, 100)
Long: pivot low(low, left pivot lookback, right pivot lookback) is not na OR balance flow > upper balance threshold
Short: pivot high(high, left pivot lookback, right pivot lookback) is not na OR balance flow ≤ lower balance threshold