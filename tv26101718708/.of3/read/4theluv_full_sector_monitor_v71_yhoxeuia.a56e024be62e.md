Calculation: sector change = (close(T1, current bar) - close(T1, prior bar)) / close(T1, prior bar) * 100; sampled on chart bars using the current, possibly still-forming T1 bar
Calculation: RVOL = volume(T1, current bar) / SMA(volume, lookback, T1, current bar); sampled on chart bars using the current, possibly still-forming T1 bar
Calculation: breadth = count of sector changes >= 0
Calculation: strength = sector change * min(RVOL, volume cap)
Long: sector change > 0 AND RVOL >= strong RVOL threshold
Short: sector change < 0 AND RVOL >= strong RVOL threshold
Long: breadth >= uptrend breadth threshold
Short: breadth <= downtrend breadth threshold
Long: strength > high-conviction threshold