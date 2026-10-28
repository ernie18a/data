Calculation: Volume spike = current volume >= SMA(volume, lookback) × volume threshold multiplier
Calculation: Average spread = SMA(high − low, same lookback as volume spike)
Long: Volume spike AND (high − low) >= average spread × spread multiplier AND close > open
Short: Volume spike AND (high − low) >= average spread × spread multiplier AND close <= open