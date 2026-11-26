Calculation: Active opening-range high and low = maximum high and minimum low of chart bars in the active enabled session window
Calculation: Opening-range size = opening-range high − opening-range low
Calculation: Value-area high = opening-range high − value-area fraction × opening-range size
Calculation: Value-area low = opening-range low + value-area fraction × opening-range size
Calculation: Third target price = entry price plus opening-range size × third-target parameter for long positions, or minus it for short positions
Long: The active opening range is formed, the bar is outside an enabled session window, and close > opening-range high OR close > value-area high on each of the confirmation-lookback consecutive chart bars
Short: The active opening range is formed, the bar is outside an enabled session window, and close < opening-range low OR close < value-area low on each of the confirmation-lookback consecutive chart bars
Exit: long, low <= opening-range low OR high >= third target price OR (high > opening-range high AND close < opening-range high)
Exit: short, high >= opening-range high OR low <= third target price OR (low < opening-range low AND close > opening-range low)