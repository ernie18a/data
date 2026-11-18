Calculation: P = open of the higher-timeframe bar containing the previous chart bar
Calculation: H = highest of P over the last lookback chart bars, including the current bar
Calculation: L = lowest of P over the last lookback chart bars, including the current bar, using the same lookback as H
Long: close > H AND H[2] > H[1]
Short: close < L AND L[2] > L[1]
Exit: long, high >= entry price + profit distance
Exit: short, low <= entry price - profit distance
Exit: long, low <= entry price - stop distance
Exit: short, high >= entry price + stop distance
Exit: long, highest high since entry >= entry price + trailing distance AND low <= highest high since entry - trailing distance
Exit: short, lowest low since entry <= entry price - trailing distance AND high >= lowest low since entry + trailing distance