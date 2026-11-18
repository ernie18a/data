Calculation: high_average = arithmetic mean of seven averages of high over the length parameter: simple moving average; exponential moving average; weighted moving average; Arnaud Legoux moving average with ALMA offset parameter and ALMA sigma parameter; Wilder-smoothed average; least-squares linear regression value at linear regression offset parameter; volume-weighted moving average
Calculation: low_average = arithmetic mean of the same seven averages as high_average, applied to low instead of high
Long: close > high_average
Short: close < low_average
Exit: long, low crosses below low_average
Exit: short, high crosses above high_average
Exit: long, close < low_average
Exit: short, close > high_average
Exit: long, high >= entry price + long take-profit parameter × close
Exit: long, low <= entry price - long stop-loss parameter × close
Exit: short, low <= entry price - short take-profit parameter × close
Exit: short, high >= entry price + short stop-loss parameter × close