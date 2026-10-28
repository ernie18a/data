Calculation: Tick imbalance = 0.65 × ((up ticks − down ticks) / tick count) + 0.35 × ((up-tick volume − down-tick volume) / total volume); classify each lower-timeframe bar by its close change from the preceding lower-timeframe close, carrying the prior direction on ties. If no lower-timeframe bars are available, use (close − open) / (high − low) for both imbalance terms.
Calculation: Spread tightness = rolling Z-score of the EMA of (high − low) / close.
Calculation: Micro momentum = tanh of the rolling Z-score of the difference between a faster and a slower EMA of close.
Calculation: Edge = clamp(decay × prior edge + weighted contribution, −3.5, 3.5), where contribution is the weighted sum of clamped tick imbalance, micro momentum, and sign(micro momentum) × clamp(−spread tightness / 2, −1, 1); weights may be normalized to sum to 1.
Long: Edge crosses above the positive threshold AND bars since the previous long signal ≥ cooldown.
Short: Edge crosses below the negative threshold AND bars since the previous short signal ≥ cooldown.
