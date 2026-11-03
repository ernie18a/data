Calculation: Opening range high = high of the first session bar
Calculation: Opening range low = low of the first session bar
Calculation: Opening range size = opening range high − opening range low
Calculation: Opening range percentage = opening range size ÷ opening range low
Long: opening range is set AND current bar is in session after the opening range bar AND opening range percentage ≤ threshold AND close > opening range high AND previous close ≤ opening range high AND current day is not Tuesday
Short: opening range is set AND current bar is in session after the opening range bar AND opening range percentage ≤ threshold AND close < opening range low AND previous close ≥ opening range low