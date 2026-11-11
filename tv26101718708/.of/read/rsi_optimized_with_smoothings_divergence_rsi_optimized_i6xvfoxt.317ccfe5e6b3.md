Calculation: RSI smoothing average = arithmetic mean of six moving averages of RSI, using the same moving-average type and independently configurable lengths.
Calculation: RSI midpoint = (RSI + RSI smoothing average) / 2.
Calculation: Confirmed RSI pivot = an RSI pivot high or low identified using configurable left and right lookbacks; evaluate it on the bar where the right lookback completes. For consecutive pivots of the same type, the range test is the number of bars between their confirmation bars minus one, within inclusive configurable lower and upper bounds.
Long: RSI > RSI smoothing average.
Short: RSI < RSI smoothing average.
Long: RSI <= oversold threshold.
Short: RSI >= overbought threshold.
Long: RSI midpoint >= midpoint threshold.
Short: RSI midpoint < midpoint threshold.
Long: RSI > upper neutral-zone threshold AND RSI <= overbought threshold.
Short: RSI < lower neutral-zone threshold AND RSI >= oversold threshold.
Long: short-length RSI moving average > long-length RSI moving average, using the same moving-average type as the six RSI smoothings.
Short: short-length RSI moving average < long-length RSI moving average, using the same moving-average type as the six RSI smoothings.
Long: a confirmed RSI pivot low passes the range test AND its RSI is greater than the previous confirmed RSI pivot low's RSI AND its bar's low is less than the previous pivot bar's low.
Short: a confirmed RSI pivot high passes the range test AND its RSI is less than the previous confirmed RSI pivot high's RSI AND its bar's high is greater than the previous pivot bar's high.