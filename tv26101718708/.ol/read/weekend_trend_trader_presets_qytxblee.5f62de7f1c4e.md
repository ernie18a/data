Calculation: N-bar highest high = highest high of the previous N completed chart bars, excluding the current bar
Calculation: N-bar ROC (%) = 100 × (current close − close N chart bars earlier) / close N chart bars earlier
Long: close > N-bar highest high AND N-bar ROC > momentum threshold
Calculation: index SMA = simple moving average of same-timeframe index closes
Calculation: trailing stop = the greater of the previous trailing stop and the highest high since entry multiplied by (1 − stop percentage / 100); initialize it from the entry bar high. Use a wider stop percentage when the index close is above its SMA and a tighter percentage otherwise.
Exit: long, close < trailing stop