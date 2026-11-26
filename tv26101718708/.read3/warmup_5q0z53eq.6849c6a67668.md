Calculation: Fast blend = SMA(T1 still-forming bar open sampled on chart bars, shorter lookback) + SMA(T1 still-forming bar open sampled on chart bars, medium lookback)/2
Calculation: Middle blend = SMA(T1 still-forming bar open sampled on chart bars, medium lookback) + SMA(T1 still-forming bar open sampled on chart bars, longer lookback)/2
Calculation: Slow blend = SMA(T1 still-forming bar open sampled on chart bars, longer lookback) + SMA(T1 still-forming bar open sampled on chart bars, longest lookback)/2
Long: Fast blend crosses above Slow blend AND Fast blend > Middle blend
Short: Fast blend crosses below Slow blend AND Fast blend < Middle blend
Exit: long, high >= entry price + profit target (ticks)
Exit: short, low <= entry price - profit target (ticks)