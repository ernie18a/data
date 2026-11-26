Calculation: Fast = moving average of MFI(high, low, close, volume, MFI lookback) with fast lookback, selected method, and phase, calculated on T1 bars
Calculation: Slow = moving average of Fast with slow lookback, the same selected method and phase, calculated on T1 bars
Long: Fast[1] (last completed T1 bar) > Slow[1] AND Fast[0] (forming T1 bar) <= Slow[0]
Short: Fast[1] (last completed T1 bar) < Slow[1] AND Fast[0] (forming T1 bar) >= Slow[0]
Exit: long, Fast[1] (last completed T1 bar) < Slow[1]
Exit: short, Fast[1] (last completed T1 bar) > Slow[1]