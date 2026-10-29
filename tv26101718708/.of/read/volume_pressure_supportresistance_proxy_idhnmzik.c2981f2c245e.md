Calculation: Support = latest confirmed pivot low, using a lookback on both sides
Calculation: Resistance = latest confirmed pivot high, using a lookback on both sides
Calculation: High volume = volume > simple moving average of volume × a multiplier
Calculation: Strong close = close > low + (high − low) × a threshold
Calculation: Weak close = close < low + (high − low) × a threshold
Calculation: Volume delta proxy = volume × (2 × (close − low) / (high − low) − 1); use zero when high = low
Long: close crosses above Resistance AND volume is high AND close is strong AND volume delta proxy > 0
Long: (low ≤ Support × (1 + a tolerance) OR low crosses below Support) AND volume is high AND close is strong AND volume delta proxy > 0
Short: close crosses below Support AND volume is high AND close is weak AND volume delta proxy < 0
Short: (high ≥ Resistance × (1 − a tolerance) OR high crosses above Resistance) AND volume is high AND close is weak AND volume delta proxy < 0