Calculation: H = maximum, over the last H lookback bars including the current bar, of the open of the last completed reference-timeframe bar
Calculation: L = minimum, over the last L lookback bars including the current bar, of the open of the last completed reference-timeframe bar
Calculation: highest high since entry = maximum of high from the entry bar through the current bar
Calculation: lowest low since entry = minimum of low from the entry bar through the current bar
Long: close > H AND H[2] > H[1]
Short: close < L AND L[2] > L[1]
Exit: long, high >= entry price + long profit target OR low <= entry price - long loss limit OR low <= highest high since entry - long trailing distance
Exit: short, low <= entry price - short profit target OR high >= entry price + short loss limit OR high >= lowest low since entry + short trailing distance