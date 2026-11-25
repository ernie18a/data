Calculation: Most recent pivot high = high of the most recent bar aged from minimum pivot age through maximum pivot age whose high is greater than or equal to the highs of the pivot-width bars on either side
Calculation: Most recent pivot low = low of the most recent bar aged from minimum pivot age through maximum pivot age whose low is less than or equal to the lows of the pivot-width bars on either side
Calculation: Long initial stop = most recent pivot low − stop offset × minimum price increment
Calculation: Short initial stop = most recent pivot high + stop offset × minimum price increment
Calculation: Long take-profit = entry price + (entry price − long initial stop) × risk-reward ratio
Calculation: Short take-profit = entry price − (short initial stop − entry price) × risk-reward ratio
Calculation: Long stop = entry price + trailing fraction × abs(close − entry price) when abs(close − entry price) ≥ abs(long take-profit − entry price) × trailing activation fraction and this value > previous long stop + minimum price increment; otherwise previous long stop; initial value = long initial stop
Calculation: Short stop = entry price − trailing fraction × abs(close − entry price) when abs(close − entry price) ≥ abs(short take-profit − entry price) × trailing activation fraction and this value < previous short stop − minimum price increment; otherwise previous short stop; initial value = short initial stop
Long: prediction confidence ≥ confidence threshold AND (predicted class = 2 OR predicted class = 3) AND close > SMA(close, lookback)
Short: prediction confidence ≥ confidence threshold AND (predicted class = 0 OR predicted class = 1) AND close ≤ SMA(close, lookback)
Exit: long, low ≤ long stop OR high ≥ long take-profit
Exit: short, high ≥ short stop OR low ≤ short take-profit