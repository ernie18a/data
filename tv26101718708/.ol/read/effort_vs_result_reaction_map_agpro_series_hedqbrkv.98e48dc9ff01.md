Calculation: Effort = (volume / average volume over a longer lookback × volume weight) + (true range / ATR × (1 − volume weight))
Calculation: Effort score = min(Effort / high-effort threshold × 100, 150)
Calculation: Progress direction = sign(close − close N bars ago); if equal, use sign(close − open), treating equality as up
Calculation: Directional close score = close location within the bar × 100 when progress direction is up; (1 − close location) × 100 when down
Calculation: Result score = min(0.62 × min(abs(close − close N bars ago) / ATR / strong-progress ATR multiple × 100, 130) + 0.38 × directional close score, 100)
Calculation: Wick balance = (upper wick − lower wick) / bar range
Calculation: Attempt direction = candle direction, except when absolute wick balance is at least its threshold, then use the sign of wick balance
Calculation: Failed-progress confidence = min(0.50 × effort score + 0.35 × (100 − result score) + 0.15 × absolute wick balance × 100, 100)
Calculation: Low-effort-progress confidence = min(0.35 × (100 − effort score) + 0.50 × result score + 0.15 × directional close score, 100)
Long: ((Effort ≥ high-effort threshold AND result score ≤ poor-result threshold AND attempt direction < 0 AND failed-progress confidence ≥ minimum confidence) OR (Effort ≤ low-effort threshold AND result score ≥ strong-result threshold AND progress direction > 0 AND low-effort-progress confidence ≥ minimum confidence)) AND (no prior accepted event OR chart bars since prior accepted event ≥ cooldown) AND bar is closed
Short: ((Effort ≥ high-effort threshold AND result score ≤ poor-result threshold AND attempt direction > 0 AND failed-progress confidence ≥ minimum confidence) OR (Effort ≤ low-effort threshold AND result score ≥ strong-result threshold AND progress direction < 0 AND low-effort-progress confidence ≥ minimum confidence)) AND (no prior accepted event OR chart bars since prior accepted event ≥ cooldown) AND bar is closed