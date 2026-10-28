Calculation: Price source = hlcc4 for presets that select it; otherwise close
Calculation: Upper ratchet = highest of EMA-smoothed highs over a lookback minus Wilder ATR times a shared volatility multiplier
Calculation: Lower ratchet = lowest of EMA-smoothed lows over the same lookback plus Wilder ATR times the same volatility multiplier
Calculation: Bullish ratchet candidate = max(current upper ratchet, prior active ratchet line)
Calculation: Bearish ratchet candidate = min(current lower ratchet, prior active ratchet line)
Long: prior trend is bearish AND price source > bearish ratchet candidate
Short: prior trend is bullish AND price source < bullish ratchet candidate
Exit: long, price source < bullish ratchet candidate
Exit: short, price source > bearish ratchet candidate