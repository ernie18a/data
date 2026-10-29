Calculation: Instantaneous trendline = recursively filter (high + low) / 2: Iₜ = (α − α²/4)Mₜ + (α²/2)Mₜ₋₁ − (α − 3α²/4)Mₜ₋₂ + 2(1 − α)Iₜ₋₁ − (1 − α)²Iₜ₋₂, where Mₜ = (highₜ + lowₜ) / 2 and α is the filter coefficient.
Calculation: Trigger = 2 × instantaneous trendline − instantaneous trendline from two bars earlier
Long: Instantaneous trendline > Trigger
Short: Instantaneous trendline < Trigger