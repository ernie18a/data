Calculation: Buy pressure = volume × (0.5 + 0.5 × clamp((close − open) / (high − low), −1, 1)); sell pressure = volume − buy pressure (if high = low, use a body bias of 0)
Calculation: Rolling buy pressure and rolling sell pressure = their respective simple moving averages over the same lookback
Calculation: Rolling buy-pressure share = rolling buy pressure / (rolling buy pressure + rolling sell pressure)
Calculation: Bull streak = consecutive bars where buy pressure / (buy pressure + sell pressure) ≥ dominance threshold; resets when this condition fails
Calculation: Bear streak = consecutive bars where buy pressure / (buy pressure + sell pressure) ≤ 100% − dominance threshold; resets when this condition fails
Long: rolling buy-pressure share ≥ dominance threshold OR prior bull streak > 0 AND current bull streak = 0 AND prior bull streak ≥ label minimum
Short: rolling buy-pressure share ≤ 100% − dominance threshold OR prior bear streak > 0 AND current bear streak = 0 AND prior bear streak ≥ label minimum