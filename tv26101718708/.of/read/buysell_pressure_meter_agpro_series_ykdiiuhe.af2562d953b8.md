Calculation: Buy pressure = volume × (1 + clamp((close - open) / (high - low), -1, 1)) / 2; use a body bias of 0 when high = low. Sell pressure = volume - buy pressure.
Calculation: Bar bull percentage = 100 × buy pressure / (buy pressure + sell pressure), or 50 when total pressure is zero.
Calculation: Rolling bull percentage = 100 × SMA of buy pressure / (SMA of buy pressure + SMA of sell pressure), using the same lookback for both SMAs, or 50 when their sum is zero.
Calculation: Bull bar = bar bull percentage >= dominance threshold. Bear bar = bar bull percentage <= 100 - dominance threshold AND bar bull percentage < dominance threshold.
Calculation: Bull streak and bear streak = consecutive counts of bull bars and bear bars respectively, reset to zero on any other bar.
Calculation: Rolling bull state = rolling bull percentage >= dominance threshold. Rolling bear state = rolling bull percentage <= 100 - dominance threshold AND rolling bull percentage < dominance threshold.
Calculation: Session net pressure = cumulative sum of buy pressure - sell pressure since the start of the current trading day, including the current bar.
Long: Rolling bull percentage >= dominance threshold.
Short: Rolling bull percentage <= 100 - dominance threshold AND rolling bull percentage < dominance threshold.
Long: Bull streak > 0.
Short: Bear streak > 0.
Long: Session net pressure > 0.
Short: Session net pressure < 0.
Long: Rolling bull state = true AND the most recent previous non-neutral rolling state = bear.
Short: Rolling bear state = true AND the most recent previous non-neutral rolling state = bull.
Long: Previous bar's bull streak >= minimum label length AND current bull streak = 0.
Short: Previous bar's bear streak >= minimum label length AND current bear streak = 0.
Long: Bull streak = minimum alert length.
Short: Bear streak = minimum alert length.