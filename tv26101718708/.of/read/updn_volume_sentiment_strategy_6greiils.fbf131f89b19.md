Calculation: Up/down volume ratio = SMA(volume when close > previous close, smoothing length) / SMA(volume when close < previous close, smoothing length)
Calculation: Sentiment oscillator = (up/down volume ratio − rolling lowest ratio over normalization lookback) / (rolling highest ratio over normalization lookback − rolling lowest ratio over normalization lookback) × 100
Long: Sentiment oscillator ≤ long entry threshold
Short: Sentiment oscillator ≥ short entry threshold
Exit: Long, low ≤ entry price × (1 − stop percentage) OR high ≥ entry price × (1 + stop percentage × profit target R multiple)
Exit: Short, high ≥ entry price × (1 + stop percentage) OR low ≤ entry price × (1 − stop percentage × profit target R multiple)