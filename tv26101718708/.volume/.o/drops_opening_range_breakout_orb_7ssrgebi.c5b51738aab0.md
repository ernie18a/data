Calculation: Opening range high = highest high during the opening-range period, fixed when that period ends
Calculation: Opening range low = lowest low during the opening-range period, fixed when that period ends
Calculation: Range midpoint = (opening range high + opening range low) / 2
Calculation: ATR = average true range over a lookback period on the chart timeframe
Calculation: Daily EMA = exponential moving average of daily closes over a longer lookback
Calculation: Volume average = average volume over a shorter lookback on the chart timeframe
Long: Opening range is defined AND range size is within configured minimum and maximum multiples of ATR AND no entry has been submitted today AND time is within the entry window AND close crosses above opening range high AND volume exceeds its average times a configured multiplier AND current daily close is above its daily EMA
Short: Opening range is defined AND range size is within configured minimum and maximum multiples of ATR AND no entry has been submitted today AND time is within the entry window AND close crosses below opening range low AND volume exceeds its average times a configured multiplier AND current daily close is below its daily EMA
Exit: Long, low <= active stop OR high >= target OR time is at or past the cutoff before market close
Exit: Short, high >= active stop OR low <= target OR time is at or past the cutoff before market close