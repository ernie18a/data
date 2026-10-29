Calculation: Session VWAP = cumulative sum of typical price × volume since the primary session began / cumulative volume since the primary session began
Calculation: Harmonic blend = 0.62 × sin(2π × session phase) + 0.38 × sin(4π × session phase + π/4), where session phase is the session bar count modulo the cycle length divided by the cycle length
Calculation: Drift ATR = EMA(close − session VWAP, drift smoothing length) / ATR
Calculation: Orbit width = ATR × (0.75 + 0.55 × absolute harmonic blend + 0.16 × absolute drift ATR)
Calculation: Orbit mean = session VWAP + 0.42 × harmonic blend × orbit width
Calculation: Upper orbit = orbit mean + orbit width
Calculation: Lower orbit = orbit mean − orbit width
Calculation: Phase pressure = clamp((close − session low) / session range − 0.5, −1, 1) × 100 + 12 × drift ATR + 22 × harmonic blend, clamped to [−100, 100], where session range is the greater of session high − session low and the minimum price increment
Calculation: Anomaly rank = percentile rank over the anomaly memory of absolute log return divided by its simple moving average over the anomaly memory
Calculation: Entropy percentage = binary Shannon entropy of volume-weighted up-candle and down-candle energy shares over the entropy memory, divided by ln(2) and multiplied by 100
Calculation: Lattice score = 0.38 × anomaly rank + 0.34 × absolute phase pressure + 0.28 × (100 − entropy percentage), clamped to [0, 100]
Long: bar is closed AND within the primary session AND close < lower orbit AND phase pressure < 0 AND lattice score ≥ phase anomaly gate
Short: bar is closed AND within the primary session AND close > upper orbit AND phase pressure > 0 AND lattice score ≥ phase anomaly gate