Calculation: BarDelta = volume * ((close - low) - (high - close)) / (high - low), or 0 when high - low = 0
Calculation: CVD = sum of BarDelta from the start of the current trading session through the current bar
Long: CVD >= 0
Short: CVD < 0