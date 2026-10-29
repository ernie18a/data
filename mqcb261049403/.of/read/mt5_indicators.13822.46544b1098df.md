Calculation: Instantaneous trend = For price P on each bar, initialize with (Pₜ + 2Pₜ₋₁ + Pₜ₋₂)/4; thereafter compute (α − α²/4)Pₜ + (α²/2)Pₜ₋₁ − (α − 3α²/4)Pₜ₋₂ + 2(1 − α)Iₜ₋₁ − (1 − α)²Iₜ₋₂, where I is the instantaneous trend; on a higher timeframe, use the value sampled at the opening of its still-forming bar.
Calculation: Trigger = 2 × instantaneous trend − instantaneous trend from two bars earlier.
Long: Trigger > instantaneous trend
Short: Instantaneous trend > Trigger