Calculation: Short moving average = selected SMA, EMA, WMA, VWMA, or HMA of close over the shorter lookback
Calculation: Long moving average = selected SMA, EMA, WMA, VWMA, or HMA of close over the longer lookback
Calculation: Long profit target = entry price × (1 + target percentage)
Calculation: Short profit target = entry price ÷ (1 + target percentage)
Calculation: Fixed long stop = entry price × (1 − stop percentage)
Calculation: Fixed short stop = entry price × (1 + stop percentage)
Calculation: Trailing long stop = maximum of the prior trailing stop and close × (1 − stop percentage); initialize at the fixed long stop
Calculation: Trailing short stop = minimum of the prior trailing stop and close × (1 + stop percentage); initialize at the fixed short stop
Long: flat AND short moving average crosses above long moving average AND long entries are enabled AND within the configured date range and, if enabled, intraday session
Short: flat AND short moving average crosses below long moving average AND short entries are enabled AND within the configured date range and, if enabled, intraday session
Exit: Long, high ≥ an enabled partial profit target OR high ≥ final profit target OR low ≤ configured stop OR (reversal closing enabled AND short moving average crosses below long moving average) OR configured session close
Exit: Short, low ≤ an enabled partial profit target OR low ≤ final profit target OR high ≥ configured stop OR (reversal closing enabled AND short moving average crosses above long moving average) OR configured session close