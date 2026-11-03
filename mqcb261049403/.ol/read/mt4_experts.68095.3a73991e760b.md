Calculation: Opening range high/low = highest high and lowest low of completed chart-timeframe bars during the first four hours of each New York local day; freeze the range after that window
Calculation: Long stop = lowest low from the consecutive completed bars closing below the opening range low, starting with the preceding bar
Calculation: Short stop = highest high from the consecutive completed bars closing above the opening range high, starting with the preceding bar
Calculation: Long target = entry price + 2 × (entry price − long stop)
Calculation: Short target = entry price − 2 × (short stop − entry price)
Long: No open position AND latest completed close > opening range low AND preceding completed close < opening range low AND the preceding closes below the opening range low do not extend through the 15th-most-recent bar
Short: No open position AND latest completed close < opening range high AND preceding completed close > opening range high AND the preceding closes above the opening range high do not extend through the 15th-most-recent bar
Exit: Long, low ≤ long stop OR high ≥ long target
Exit: Short, high ≥ short stop OR low ≤ short target