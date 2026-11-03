Calculation: Long-lookback linear regression = Endpoint of the least-squares linear regression of close over the longer lookback
Calculation: Long-lookback trigger = Exponential moving average of the long-lookback linear regression, using a longer smoothing lookback than the short-lookback trigger
Calculation: Short-lookback linear regression = Endpoint of the least-squares linear regression of close over the shorter lookback
Calculation: Short-lookback trigger = Exponential moving average of the short-lookback linear regression
Long: Long-lookback linear regression > long-lookback trigger AND short-lookback linear regression > short-lookback trigger
Short: Long-lookback linear regression < long-lookback trigger AND short-lookback linear regression < short-lookback trigger