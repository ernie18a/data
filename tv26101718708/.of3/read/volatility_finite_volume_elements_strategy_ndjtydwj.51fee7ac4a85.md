Calculation: momentum = close - (high + low)/2 + (high + low + close)/3 - ((high + low + close)/3)[1]
Calculation: threshold = intrabar coefficient × STDEV(log(high) - log(low), sample lookback) + interbar coefficient × STDEV(log((high + low + close)/3) - log(((high + low + close)/3)[1]), sample lookback)
Calculation: direction state = 1 if momentum > threshold × close, else -1 if momentum < -threshold × close, else prior direction state (initially 0)
Long: reversal setting enabled AND direction state = -1 OR reversal setting disabled AND direction state = 1
Short: reversal setting enabled AND direction state = 1 OR reversal setting disabled AND direction state = -1