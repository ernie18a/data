Calculation: POC = mode of close over the current and prior lookback bars
Calculation: Standard deviation = standard deviation of close over the current and prior lookback bars
Calculation: VAH = POC + standard deviation
Calculation: VAL = POC - standard deviation
Long: close > VAL AND prior close <= prior VAL
Short: close < VAH AND prior close >= prior VAH
Exit: long, high >= POC
Exit: short, low <= POC