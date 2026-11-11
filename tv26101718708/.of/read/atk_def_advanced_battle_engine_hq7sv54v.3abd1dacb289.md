Calculation: Price change = 100 × (close − previous close) / (previous close + 0.0001).
Calculation: Volume change = 100 × (volume − previous volume) / (previous volume + 0.0001).
Calculation: Movement = price change × volume change / 100.
Calculation: Tracking = (clamp(100 × (movement − SMA of movement) / (SMA of movement + 0.0001), −100, 100) + 100) / 2.
Calculation: Attraction = clamp(SMA of (movement − price change), −100, 100), using a shorter lookback than the movement SMA.
Calculation: Behavior score = min((tracking + absolute attraction) / 2, 100).
Long: Behavior score > bullish lower threshold AND behavior score <= bullish upper threshold.
Short: Behavior score > bearish lower threshold AND behavior score <= bearish upper threshold.