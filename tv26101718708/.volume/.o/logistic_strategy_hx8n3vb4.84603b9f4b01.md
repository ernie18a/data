Calculation: Net volume = volume when close > previous bar close; otherwise −volume
Calculation: Net-volume score = short-lookback moving average of net volume / longer-lookback standard deviation of net volume
Calculation: Logistic prediction = (close + close standard deviation) / (1 + (close standard deviation / close) × exp(−net-volume score))
Calculation: Close standard deviation = standard deviation of close over a trailing lookback including the current bar
Long: Logistic prediction > close × (1 + entry threshold)
Exit: Long, Logistic prediction < close × (1 − exit threshold)