Calculation: Delta = (close - open) × volume
Calculation: Bull imbalance strength = max(0, previous bull imbalance + Delta) × decay / 50-bar SMA(abs(Delta))
Calculation: Bear imbalance strength = max(0, previous bear imbalance - Delta) × decay / 50-bar SMA(abs(Delta))
Long: Bear imbalance strength > threshold AND Delta > 0
Short: Bull imbalance strength > threshold AND Delta < 0
Exit: Long, low <= close - 2 × ATR(14) OR high >= close + 3 × ATR(14)
Exit: Short, high >= close + 2 × ATR(14) OR low <= close - 3 × ATR(14)