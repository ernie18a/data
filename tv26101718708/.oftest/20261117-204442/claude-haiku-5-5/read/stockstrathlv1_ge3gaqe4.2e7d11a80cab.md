Calculation: H = highest of the timeframe-A open as of one chart bar earlier, over the last N_H chart bars; the timeframe-A bar may still be forming, and only its open is used
Calculation: L = lowest of the timeframe-A open as of one chart bar earlier, over the last N_L chart bars; the timeframe-A bar may still be forming, and only its open is used
Long: close[2] > H AND H[2] > H[1] AND close > H
Short: close[2] < L AND L[2] > L[1] AND close < L
Calculation: peak high = highest high from the entry bar through the current bar
Calculation: trough low = lowest low from the entry bar through the current bar
Exit: long, high >= entry price + profit points
Exit: long, low <= entry price - loss points
Exit: long, peak high >= entry price + trail points AND low <= peak high - trail points
Exit: short, low <= entry price - profit points
Exit: short, high >= entry price + loss points
Exit: short, trough low <= entry price - trail points AND high >= trough low + trail points