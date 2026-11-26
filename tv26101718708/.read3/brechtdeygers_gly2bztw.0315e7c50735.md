Calculation: long entry level = demand zone top on signal bar - ((demand zone top - demand zone bottom) * entry-depth percentage / 100)
Calculation: long stop level = demand zone bottom on signal bar - (ATR(ATR lookback) on signal bar * stop buffer)
Calculation: long target level = long entry level + ((long entry level - long stop level) * risk:reward)
Calculation: short entry level = supply zone bottom on signal bar + ((supply zone top - supply zone bottom) * entry-depth percentage / 100)
Calculation: short stop level = supply zone top on signal bar + (ATR(ATR lookback) on signal bar * stop buffer)
Calculation: short target level = short entry level - ((short stop level - short entry level) * risk:reward)
Long: a fresh, unmitigated demand zone with no prior touch since formation has its bottom <= low <= top, and close > EMA(close, trend lookback)
Short: a fresh, unmitigated supply zone with no prior touch since formation has its bottom <= high <= top, and close < EMA(close, trend lookback)
Exit: long, high >= long target level OR low <= long stop level
Exit: short, low <= short target level OR high >= short stop level