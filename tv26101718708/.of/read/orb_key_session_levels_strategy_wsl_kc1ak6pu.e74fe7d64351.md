Calculation: Opening-range high = highest high during the configured opening-range session for the current day
Calculation: Opening-range low = lowest low during the configured opening-range session for the current day
Calculation: Opening-range midpoint = (opening-range high + opening-range low) / 2
Calculation: Stop level = configured opening-range midpoint, opposite opening-range boundary, or fixed distance from entry price, according to the selected stop method
Calculation: Risk distance = absolute difference between entry price and stop level
Calculation: Profit targets = entry price plus (long) or minus (short) risk distance multiplied by each configured reward-to-risk multiple
Long: Opening range is complete AND no entry signal has fired today AND (entry mode is Breakout AND close crosses above opening-range high OR entry mode is Retest Zone AND a prior close crossed above opening-range high and, within the configured timeout, low <= opening-range high AND close > opening-range high OR entry mode is Retest Midpoint AND a prior close crossed above opening-range high and, within the configured timeout, low <= opening-range midpoint AND close > opening-range high)
Short: Opening range is complete AND no entry signal has fired today AND (entry mode is Breakout AND close crosses below opening-range low OR entry mode is Retest Zone AND a prior close crossed below opening-range low and, within the configured timeout, high >= opening-range low AND close < opening-range low OR entry mode is Retest Midpoint AND a prior close crossed below opening-range low and, within the configured timeout, high >= opening-range midpoint AND close < opening-range low)
Exit: Long, low <= stop level
Exit: Long, high >= first profit target
Exit: Long, high >= second profit target
Exit: Long, high >= third profit target
Exit: Short, high >= stop level
Exit: Short, low <= first profit target
Exit: Short, low <= second profit target
Exit: Short, low <= third profit target