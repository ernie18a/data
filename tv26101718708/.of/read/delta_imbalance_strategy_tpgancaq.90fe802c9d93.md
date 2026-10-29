Calculation: Delta = (close - open) × volume
Calculation: Bull imbalance = max(0, prior bull imbalance + max(Delta, 0) - max(-Delta, 0)) × decay
Calculation: Bear imbalance = max(0, prior bear imbalance + max(-Delta, 0) - max(Delta, 0)) × decay
Calculation: Average absolute Delta = moving average of absolute Delta over a configurable lookback
Calculation: Bull strength = bull imbalance / average absolute Delta
Calculation: Bear strength = bear imbalance / average absolute Delta
Long: Bear strength > imbalance threshold AND Delta > 0
Short: Bull strength > imbalance threshold AND Delta < 0
Exit: Long, low ≤ close - 2 × ATR OR high ≥ close + 3 × ATR
Exit: Short, high ≥ close + 2 × ATR OR low ≤ close - 3 × ATR