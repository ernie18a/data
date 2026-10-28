Calculation: Close location value = ((close − low) − (high − close)) / max(high − low, minimum price increment)
Calculation: Body share = (close − open) / max(high − low, minimum price increment)
Calculation: Volume pulse = volume / EMA(volume, pressure lookback)
Calculation: Pressure strength = clamp(155 × C / (1 + abs(C)), −100, 100), where C = 0.72 × EMA(close location value × volume, pressure lookback) / EMA(volume, pressure lookback) + 0.28 × EMA(body share × min(volume pulse, 3), pressure lookback); use the same pressure lookback for all EMAs here
Calculation: Blended basis = ALMA(source, basis lookback) × blend weight + EMA(source, basis lookback) × (1 − blend weight); use the same basis lookback for ALMA and EMA
Calculation: Cloud distance = ATR(ATR lookback) × cloud multiplier × (1 + abs(pressure strength) / 100 × 0.70 + clamp(volume pulse − 1, 0, 2) × 0.12)
Calculation: Inner upper cloud = blended basis + cloud distance × 0.38
Calculation: Inner lower cloud = blended basis − cloud distance × 0.38
Long: (pressure strength crosses above signal threshold AND close > blended basis) OR (pressure strength > signal threshold AND low ≤ inner upper cloud AND close > blended basis AND the previous bar did not satisfy all three conditions)
Short: (pressure strength crosses below negative signal threshold AND close < blended basis) OR (pressure strength < negative signal threshold AND high ≥ inner lower cloud AND close < blended basis AND the previous bar did not satisfy all three conditions)