Calculation: POC = most frequently occurring close over the same rolling lookback as standard deviation, including the current chart bar.
Calculation: Standard deviation = standard deviation of close over the rolling lookback used for POC, including the current chart bar.
Calculation: VAL = POC - standard deviation
Calculation: VAH = POC + standard deviation
Long: close crosses above VAL
Short: close crosses below VAH
Exit: Long, high >= POC
Exit: Short, low <= POC