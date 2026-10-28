Calculation: Opening range high = highest bar high during the configured opening-range session, or highest max(open, close) if the range source uses closes; freeze it when the session ends
Calculation: Opening range low = lowest bar low during the configured opening-range session, or lowest min(open, close) if the range source uses closes; freeze it when the session ends
Calculation: Long trailing stop = running maximum since entry of (bar low − ATR × stop multiplier)
Calculation: Short trailing stop = running minimum since entry of (bar high + ATR × stop multiplier)
Long: current close > opening range high AND previous close ≤ previous opening range high AND opening-range session has ended AND current bar is outside that session AND the long signal has not already occurred that day AND current time is within the configured plotting period
Short: current close < opening range low AND previous close ≥ previous opening range low AND opening-range session has ended AND current bar is outside that session AND the short signal has not already occurred that day AND current time is within the configured plotting period
Exit: long, close < long trailing stop OR current time is outside the configured plotting period
Exit: short, close > short trailing stop OR current time is outside the configured plotting period