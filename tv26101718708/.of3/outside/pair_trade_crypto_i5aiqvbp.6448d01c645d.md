Calculation: hedge ratio = correlation(log(LTCUSD close multiplied by the price multiplier parameter), log(XBTUSD close), lookback parameter) * (standard deviation(log(XBTUSD close), lookback parameter) / standard deviation(log(LTCUSD close multiplied by the price multiplier parameter), lookback parameter))
Calculation: pair spread = log(XBTUSD close) - (SMA(log(XBTUSD close), lookback parameter) - hedge ratio * SMA(log(LTCUSD close multiplied by the price multiplier parameter), lookback parameter) + log(LTCUSD close multiplied by the price multiplier parameter) * hedge ratio)
Short: pair spread > entry threshold parameter
Long: pair spread < -entry threshold parameter
Exit: short, pair spread < exit threshold parameter
Exit: long, pair spread > -exit threshold parameter