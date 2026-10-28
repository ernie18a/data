Calculation: Ensemble exposure = average of four 0–1 ramps, one per close SMA; each ramp is clamp((close − SMA) / (2 × sqrt(lookback / longest lookback) × ATR), 0, 1). The four lookbacks are progressively longer.
Calculation: Held exposure = nearest of N equally spaced exposure levels to ensemble exposure; update only when the raw exposure differs from the prior held exposure by at least 0.75/N. Target weight = floor + (1 − floor) × scale × held exposure.
Long: Position is flat AND held exposure > 0
Long: Target weight > previous target weight
Exit: long, Target weight < previous target weight OR held exposure = 0