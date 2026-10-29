Calculation: Opening range high = highest high from 9:30 through 9:44 AM New York time each day
Calculation: Opening range low = lowest low from 9:30 through 9:44 AM New York time each day
Calculation: Opening range midpoint = (opening range high + opening range low) / 2
Calculation: Relative volume = current bar volume / simple moving average of volume over the preceding bars, excluding the current bar
Long: after the opening range ends and before 11:00 AM New York time, close > opening range high AND previous chart bar close <= opening range high AND no prior long breakout that day AND (relative volume filter disabled OR relative volume >= threshold) AND (time, day, month, and position type filters disabled or pass)
Short: after the opening range ends and before 11:00 AM New York time, close < opening range low AND previous chart bar close >= opening range low AND no prior short breakout that day AND (relative volume filter disabled OR relative volume >= threshold) AND (time, day, month, and position type filters disabled or pass)
Exit: long, low <= stop level OR high >= take-profit level; after favorable high reaches the configured multiple of initial risk, stop level is entry price
Exit: short, high >= stop level OR low <= take-profit level; after favorable low reaches the configured multiple of initial risk, stop level is entry price