Calculation: Opening range high = highest high during the opening-range session
Calculation: Opening range low = lowest low during the opening-range session
Calculation: Opening range midpoint = (opening range high + opening range low) / 2
Calculation: Failed upside-breakout high = highest high since the first close above the opening range high
Calculation: Failed downside-breakout low = lowest low since the first close below the opening range low
Long: During the trade window, while flat and before any breakout that day, close > opening range high; OR, after the first close below the opening range low, close > opening range low AND close < opening range high AND (the continuation position is still open OR continuation entries are disabled OR reversals after the continuation closes are allowed)
Short: During the trade window, while flat and before any breakout that day, close < opening range low; OR, after the first close above the opening range high, close > opening range low AND close < opening range high AND (the continuation position is still open OR continuation entries are disabled OR reversals after the continuation closes are allowed)
Exit: Long, low <= stop price OR high >= entry price + (entry price - stop price) × reward-to-risk multiple OR trade window ended and session-end closing is enabled
Exit: Short, high >= stop price OR low <= entry price - (stop price - entry price) × reward-to-risk multiple OR trade window ended and session-end closing is enabled