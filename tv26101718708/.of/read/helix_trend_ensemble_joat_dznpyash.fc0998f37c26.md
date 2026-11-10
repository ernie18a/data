Calculation: Member = a configurable moving average of a configurable price source, optionally smoothed by a configurable moving average; use three independently configured members with nonnegative weights.
Calculation: Normalized slope = clamp((member - member at the slope lookback) / max(ATR × 0.5, 0.0001), -1, 1).
Calculation: Member direction = sign of its normalized slope.
Calculation: Consensus = sum over the three members of (member direction × member weight × (0.35 + 0.65 × absolute normalized slope)) / max(sum of member weights, 0.0001).
Calculation: Bull agreement = number of members with positive direction; bear agreement = number with negative direction.
Calculation: Regime = initially neutral; on each completed chart bar, set bullish if consensus >= entry threshold AND bull agreement >= minimum agreement AND ADX >= ADX threshold AND ATR / SMA of ATR >= volatility threshold; otherwise set bearish if consensus <= negative entry threshold AND bear agreement >= minimum agreement AND ADX >= ADX threshold AND ATR / SMA of ATR >= volatility threshold; otherwise set neutral if absolute consensus <= neutral threshold; otherwise retain the previous regime. The neutral threshold is lower than the entry threshold; division by zero in the ATR ratio returns zero.
Long: Any member's normalized slope > 0.
Short: Any member's normalized slope < 0.
Long: Regime = bullish OR (regime = neutral AND consensus > entry threshold).
Short: Regime = bearish OR (regime = neutral AND consensus < negative entry threshold).