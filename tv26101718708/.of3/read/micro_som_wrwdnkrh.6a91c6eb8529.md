Calculation: current-node bias = mean forward close-price change divided by ATR(lookback), over completed chart bars assigned to the current bar’s nearest learned SOM node, using a forward horizon
Long: current-node bias > threshold
Short: current-node bias < -threshold