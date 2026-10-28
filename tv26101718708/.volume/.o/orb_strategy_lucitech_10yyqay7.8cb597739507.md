Calculation: Opening-range high = highest high of the current session’s opening-range bars, after the opening range is complete
Calculation: Opening-range low = lowest low of the current session’s opening-range bars, after the opening range is complete
Calculation: Long initial stop = selected stop level: lower of the current bar by ATR times a multiplier, the low a configurable number of bars back, or the opening-range midpoint
Calculation: Short initial stop = selected stop level: higher of the current bar by ATR times a multiplier, the high a configurable number of bars back, or the opening-range midpoint
Calculation: Long target = entry price + reward-to-risk multiple × (entry price − long initial stop)
Calculation: Short target = entry price − reward-to-risk multiple × (short initial stop − entry price)
Long: close > opening-range high AND previous close <= opening-range high AND opening range is complete AND before the session cutoff AND no earlier long breakout this session
Short: close < opening-range low AND previous close >= opening-range low AND opening range is complete AND before the session cutoff AND no earlier short breakout this session
Exit: Long, low <= active stop OR high >= long target; after favorable high reaches the configured risk multiple, active stop becomes entry price
Exit: Short, high >= active stop OR low <= short target; after favorable low reaches the configured risk multiple, active stop becomes entry price