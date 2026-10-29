Calculation: Money-flow RSI = compute a short-lookback weighted moving average of hlc3 and volume; multiply each change in weighted price by weighted volume when positive, otherwise by 1; apply the longer-lookback Wilder moving average separately to positive and negative changes, then calculate 100 − 100/(1 + average gain/average loss)
Calculation: Range position = (short-lookback weighted average of hlc3 − lowest low over twice the longer lookback) / (highest high over twice the longer lookback − lowest low over twice the longer lookback)
Calculation: Long target = the prior bar’s 76.4% level between the active long area’s starting price and its lowest low since activation
Calculation: Short target = the prior bar’s 23.6% level between the active short area’s starting price and its highest high since activation
Long: Money-flow RSI is below its lower threshold AND higher than on the prior bar AND Range position < 0.4 AND no long area is active
Short: Money-flow RSI is above its upper threshold AND higher than on the prior bar AND Range position > 0.6 AND no short area is active
Exit: long, high > Long target
Exit: short, low < Short target