Calculation: direction state = 1 when trigger source > SMA(selected source from the last completed T1 bar, lookback), calculated on chart bars using T1 values; -1 when trigger source < that SMA; otherwise the prior direction state, initially 0
Long: direction state changes to 1 AND (alerts enabled OR reversal disabled) OR direction state changes to -1 AND reversal enabled
Short: direction state changes to -1 AND (alerts enabled OR reversal disabled) OR direction state changes to 1 AND reversal enabled
Exit: long, high > entry price + profit distance OR low < entry price - loss distance
Exit: short, low < entry price - profit distance OR high > entry price + loss distance