Calculation: Opening-range high/low/midpoint = highest high, lowest low, and their average across completed bars timestamped 09:30–09:44 New York time
Calculation: Relative volume = current bar volume divided by its moving-average volume
Long: 09:45–16:00 New York time AND opening range locked AND no trade taken today AND flat position AND previous close <= opening-range high AND current close > opening-range high AND relative volume >= minimum threshold
Short: 09:45–16:00 New York time AND opening range locked AND no trade taken today AND flat position AND previous close >= opening-range low AND current close < opening-range low AND relative volume >= minimum threshold
Exit: long, low <= opening-range midpoint OR high >= entry price + (entry price - opening-range midpoint) * risk-reward ratio OR time is 16:00 New York time
Exit: short, high >= opening-range midpoint OR low <= entry price - (opening-range midpoint - entry price) * risk-reward ratio OR time is 16:00 New York time