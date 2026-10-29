Calculation: Moving average = selected SMA, EMA, WMA, HMA, VWMA, RMA, or TEMA of the selected source
Calculation: Upper tolerance band = moving average * (1 + tolerance percentage)
Calculation: Lower tolerance band = moving average * (1 - tolerance percentage)
Long: current close > current upper tolerance band AND previous close <= previous upper tolerance band AND current date is on or after the configured start year and month
Short: current close < current lower tolerance band AND previous close >= previous lower tolerance band AND current date is on or after the configured start year and month