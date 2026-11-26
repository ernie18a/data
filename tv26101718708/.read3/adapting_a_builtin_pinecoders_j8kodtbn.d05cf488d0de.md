Long: SMA(nz(volume), MA lookback) is greater than every value in the preceding rising lookback
Short: SMA(nz(volume), MA lookback) is less than or equal to at least one value in the preceding rising lookback
Long: volume > SMA(nz(volume), MA lookback)
Short: volume <= SMA(nz(volume), MA lookback)
Long: (previous-close color mode selected AND close >= close[1]) OR (open-close color mode selected AND close >= open)
Short: (previous-close color mode selected AND close < close[1]) OR (open-close color mode selected AND close < open)