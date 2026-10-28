Calculation: True range average = simple moving average of true range over a lookback
Calculation: AlphaTrend = recursively retain the prior value or set it to low minus the true range average times a multiplier when RSI of the selected source (or MFI of hlc3) is at least 50; otherwise recursively retain the prior value or set it to high plus the true range average times a multiplier
Calculation: Bars since event = number of bars since the most recent occurrence of the event
Long: AlphaTrend crosses above its value two bars earlier AND bars since the prior-bar long crossover > bars since the current short crossover
Short: AlphaTrend crosses below its value two bars earlier AND bars since the prior-bar short crossover > bars since the current long crossover