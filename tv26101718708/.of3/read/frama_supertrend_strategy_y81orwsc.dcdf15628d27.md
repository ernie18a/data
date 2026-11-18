Calculation: FRAMA line = FRAMA(T1 source, T1 high, T1 low, lookback L, fast constant F, slow constant S), calculated on chart bars from T1 values (the forming T1 bar in real time; the last completed T1 bar historically)
Calculation: FRAMA signal = FRAMA(FRAMA line, T1 high, T1 low, same L, F, and S), calculated on chart bars from T1 values (the forming T1 bar in real time; the last completed T1 bar historically)
Long: FRAMA line crosses above FRAMA signal AND (entry Supertrend filter disabled OR Supertrend direction is up) AND (custom date filter disabled OR datetime is within the configured interval)
Short: FRAMA line crosses below FRAMA signal AND (entry Supertrend filter disabled OR Supertrend direction is down) AND (custom date filter disabled OR datetime is within the configured interval)
Long: close crosses above the Supertrend line
Short: close crosses below the Supertrend line
Long: Supertrend direction changes from down to up
Short: Supertrend direction changes from up to down
Exit: long, exit Supertrend filter enabled AND Supertrend direction is down
Exit: short, exit Supertrend filter enabled AND Supertrend direction is up
Exit: long, take profit enabled AND high >= entry price + take-profit distance
Exit: long, stop loss enabled AND low <= entry price - stop-loss distance
Exit: short, take profit enabled AND low <= entry price - take-profit distance
Exit: short, stop loss enabled AND high >= entry price + stop-loss distance
Exit: long, trailing stop distance and offset enabled AND highest high since entry >= entry price + trail offset AND low <= highest high since entry - trail distance
Exit: short, trailing stop distance and offset enabled AND lowest low since entry <= entry price - trail offset AND high >= lowest low since entry + trail distance
Exit: long, custom date filter enabled AND (datetime < configured start OR datetime > configured stop)
Exit: short, custom date filter enabled AND (datetime < configured start OR datetime > configured stop)