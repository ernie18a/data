Calculation: OpenSeries = open of the bar of timeframe TF that contains the decision bar, using the bar still forming; X[k] is the value of X k decision bars earlier
Calculation: UpperLevel = highest(OpenSeries over the N decision bars before the current one)
Calculation: LowerLevel = lowest(OpenSeries over the N decision bars before the current one)
Long: close > UpperLevel AND UpperLevel[2] > UpperLevel[1]
Short: close < LowerLevel AND LowerLevel[2] > LowerLevel[1]
Exit: long, high >= entry price + PROFIT
Exit: long, low <= entry price - LOSS
Exit: long, low <= highest high since entry - TRAIL AND highest high since entry >= entry price + TRAIL
Exit: short, low <= entry price - PROFIT
Exit: short, high >= entry price + LOSS
Exit: short, high >= lowest low since entry + TRAIL AND lowest low since entry <= entry price - TRAIL