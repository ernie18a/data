Calculation: Session high = maximum high of chart bars in the session-window parameter, using the timezone parameter, for the current day; available after the session window closes
Calculation: Session low = minimum low of chart bars in the session-window parameter, using the timezone parameter, for the current day; available after the session window closes
Long: the session range is available AND close > session high
Short: the session range is available AND close < session low
Calculation: Long stop at entry = session low if the range-stop parameter selects the range boundary, otherwise entry price - (session high - session low)
Calculation: Short stop at entry = session high if the range-stop parameter selects the range boundary, otherwise entry price + (session high - session low)
Calculation: Long target at entry = entry price + (entry price - long stop at entry) * risk-reward parameter
Calculation: Short target at entry = entry price - (short stop at entry - entry price) * risk-reward parameter
Exit: Long, low <= long stop at entry OR high >= long target at entry
Exit: Short, high >= short stop at entry OR low <= short target at entry