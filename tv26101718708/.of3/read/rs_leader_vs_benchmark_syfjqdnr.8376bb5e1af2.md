Calculation: relative strength = close / benchmark close
Calculation: relative strength trend = EMA(relative strength, trend lookback)
Calculation: rate of change = ROC(relative strength, momentum lookback)
Calculation: percent rank = PERCENTRANK(relative strength, percent rank lookback)
Calculation: leader state = relative strength > relative strength trend AND rate of change > 0 AND (NOT use percent rank filter OR percent rank >= minimum percent rank)
Long: relative strength crosses above relative strength trend
Long: leader state AND NOT leader state[1]
Long: leader state
Long: relative strength > relative strength trend
Long: rate of change > 0
Long: percent rank >= upper percent rank threshold
Short: relative strength crosses below relative strength trend
Short: relative strength is not na AND NOT (relative strength > relative strength trend)
Short: rate of change <= 0
Short: percent rank <= lower percent rank threshold
Exit: long, NOT leader state AND leader state[1]