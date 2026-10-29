Calculation: Range high = highest high of the last N completed chart-timeframe bars
Calculation: Range low = lowest low of the last N completed chart-timeframe bars
Calculation: Zone buffer = (range high − range low) × zone percentage
Calculation: Resistance level = range high − zone buffer
Calculation: Support level = range low + zone buffer
Long: Current bar close > range high
Long: Current bar close ≤ support level AND current bar close ≤ range high AND current bar close < resistance level
Short: Current bar close < range low
Short: Current bar close ≥ resistance level AND current bar close ≤ range high
Exit: 