Calculation: Money-flow Z-score = if population STDEV(Chaikin Oscillator(high, low, close, volume, shorter lookback, longer lookback), normalization lookback) > 0 then (Chaikin Oscillator(high, low, close, volume, shorter lookback, longer lookback) - SMA(Chaikin Oscillator(high, low, close, volume, shorter lookback, longer lookback), normalization lookback)) / population STDEV(Chaikin Oscillator(high, low, close, volume, shorter lookback, longer lookback), normalization lookback) else 0
Calculation: Flow regime = strong-in if Money-flow Z-score >= strong-band threshold; else mild-in if Money-flow Z-score >= mild-band threshold; else strong-out if Money-flow Z-score <= -strong-band threshold; else mild-out if Money-flow Z-score <= -mild-band threshold; else neutral
Long: Flow regime is strong-in
Long: Flow regime is mild-in
Short: Flow regime is strong-out
Short: Flow regime is mild-out
Long: Flow regime is strong-in AND Flow regime[1] is not strong-in
Short: Flow regime is strong-out AND Flow regime[1] is not strong-out
Long: Flow regime is strong-in or mild-in AND Flow regime[1] is neither strong-in nor mild-in
Short: Flow regime is strong-out or mild-out AND Flow regime[1] is neither strong-out nor mild-out
Long: close crosses above EMA(close, entry lookback)
Short: close crosses below EMA(close, entry lookback)
Long: Chaikin Oscillator(high, low, close, volume, shorter lookback, longer lookback) >= 0
Short: Chaikin Oscillator(high, low, close, volume, shorter lookback, longer lookback) < 0
Long: session restriction is disabled or datetime is within the configured session window AND (Flow regime is strong-in OR strong-only requirement is disabled AND Flow regime is mild-in) AND close crosses above EMA(close, entry lookback) AND position side is flat or short AND chart bars since the previous buy or sell signal >= cooldown lookback AND bar is confirmed
Short: session restriction is disabled or datetime is within the configured session window AND (Flow regime is strong-out OR strong-only requirement is disabled AND Flow regime is mild-out) AND close crosses below EMA(close, entry lookback) AND position side is flat or long AND chart bars since the previous buy or sell signal >= cooldown lookback AND bar is confirmed