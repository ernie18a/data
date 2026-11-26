Calculation: Buy pressure = if SUM(volume, pressure lookback) > 0 then SUM(volume × (1 / (1 + EXP(-BVC logistic coefficient × IF(STDEV(log(close / (close[1] if available else close)), BVC sigma lookback) > 0, log(close / (close[1] if available else close)) / STDEV(log(close / (close[1] if available else close)), BVC sigma lookback), 0))), pressure lookback) / SUM(volume, pressure lookback) else 0.5
Calculation: Dominant pressure percent = 100 × (buy pressure if buy pressure > dominance threshold else 1 − buy pressure)
Long: buy pressure > dominance threshold
Long: buy pressure > dominance threshold AND dominant pressure percent ≥ strong pressure threshold AND buy pressure[1] ≤ dominance threshold
Short: buy pressure ≤ dominance threshold
Short: buy pressure ≤ dominance threshold AND dominant pressure percent ≥ strong pressure threshold AND buy pressure[1] > dominance threshold