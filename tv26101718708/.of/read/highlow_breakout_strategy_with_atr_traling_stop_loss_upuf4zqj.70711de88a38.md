Calculation: Opening-range high = highest high of completed chart bars during the first 30 minutes after the session start
Calculation: Opening-range low = lowest low of completed chart bars during the first 30 minutes after the session start
Long: On a completed chart bar, close crosses above the opening-range high
Short: On a completed chart bar, close crosses below the opening-range low
Exit: Long, low <= entry price - ATR × multiplier OR high >= entry price + ATR × multiplier OR datetime is 15:15
Exit: Short, high >= entry price + ATR × multiplier OR low <= entry price - ATR × multiplier OR datetime is 15:15