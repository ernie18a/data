Calculation: Opening-range high = highest high during the first configurable number of minutes of the selected session
Calculation: Opening-range low = lowest low during the first configurable number of minutes of the selected session
Calculation: Prior-session high = highest high of the last completed selected session
Calculation: Prior-session low = lowest low of the last completed selected session
Long: (close > opening-range high AND previous close <= opening-range high) OR (low < prior-session low AND close > prior-session low)
Short: (close < opening-range low AND previous close >= opening-range low) OR (high > prior-session high AND close < prior-session high)