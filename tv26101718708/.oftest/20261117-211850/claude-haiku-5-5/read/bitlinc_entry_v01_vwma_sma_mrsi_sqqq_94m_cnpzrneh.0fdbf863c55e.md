Calculation: fastMA = simple moving average of close over fast MA length bars
Calculation: slowMA = sum over slow MA length bars of (high × volume), divided by sum of volume over the same bars
Calculation: smoothedRSI = exponential moving average over smoothing length bars of RSI of close over RSI length bars
Calculation: crossesAbove(x, y) = x > y on the current bar AND x <= y on the previous bar
Calculation: windowStart = datetime at 00:00 on the day given by window start year, window start month, and window start day
Calculation: windowEnd = datetime at 23:59 on the day given by window end year, window end month, and window end day
Calculation: inWindow = datetime >= windowStart AND datetime <= windowEnd
Long: crossesAbove(fastMA, slowMA) AND inWindow
Short: crossesAbove(slowMA, fastMA) AND inWindow
Long: crossesAbove(smoothedRSI, oversold level) AND inWindow
Short: crossesAbove(smoothedRSI, overbought level) AND inWindow
Long: fastMA > slowMA
Short: fastMA <= slowMA