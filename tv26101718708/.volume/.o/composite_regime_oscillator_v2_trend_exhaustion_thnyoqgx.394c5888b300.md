Calculation: Scaled score(x, lower, upper) = 100 × clamp((x − lower) / (upper − lower), 0, 1)
Calculation: Regime stress = 0.45 × Scaled score(fast ATR / slow ATR, 1, 1.5) + 0.30 × Scaled score((rolling highest high − close) / rolling highest high, 0, 0.12) + 0.25 × Scaled score((close − rolling lowest low) / rolling lowest low, 0, 0.10)
Calculation: Stretch = 0.70 × Scaled score((close − EMA) / fast ATR, 0, 2.8) + 0.30 × Scaled score(range position, 0.5, 1)
Calculation: Range position = (close − rolling lowest low) / (rolling highest high − rolling lowest low)
Calculation: Price location = 0.60 × Scaled score(range position, 0, 1) + 0.25 × Scaled score((close − rolling lowest low) / rolling lowest low, 0, 0.10) + 0.15 × (100 − Scaled score((rolling highest high − close) / rolling highest high, 0, 0.08))
Calculation: Overreaction = 0.75 × Scaled score(RSI, 50, 80) + 0.25 × Scaled score((close − EMA) / fast ATR, 0.5, 2.8)
Calculation: Pressure = 0.70 × Scaled score(volume / volume SMA, 0.8, 2) + 0.30 × Scaled score(fast ATR / slow ATR, 1, 1.5)
Calculation: Composite oscillator = EMA-smoothed weighted mean of regime stress, stretch, price location, overreaction, and pressure, using a configurable weight for each component
Long: Composite oscillator crosses above 80 OR (composite oscillator < 20 AND rising for 2 consecutive bars)
Short: Composite oscillator crosses below 20 OR (composite oscillator ≥ 80 AND falling for 2 consecutive bars)
Exit: long, composite oscillator ≥ 65 AND falling for 3 consecutive bars