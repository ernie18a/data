Long: on chart bars, high >= high(T1, last completed bar) + entry offset
Short: on chart bars, low <= low(T1, last completed bar) - entry offset
Calculation: long trailing stop = max(entry price - stop distance, highest high since entry - stop distance)
Calculation: short trailing stop = min(entry price + stop distance, lowest low since entry + stop distance)
Exit: long, low <= long trailing stop
Exit: short, high >= short trailing stop