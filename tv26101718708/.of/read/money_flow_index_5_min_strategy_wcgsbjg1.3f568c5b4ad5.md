Long: previous chart bar’s Money Flow Index = overbought level AND close > open AND abs(close - open) > (high - low) × body-size threshold AND (close > chart-timeframe SMA, if the moving-average filter is enabled)
Short: previous chart bar’s Money Flow Index = oversold level AND close < open AND abs(close - open) > (high - low) × body-size threshold AND (close < chart-timeframe SMA, if the moving-average filter is enabled)
Calculation: Long stop = low of the chart bar at the start of the UTC trading day × (1 − stop increment)
Calculation: Short stop = high of the chart bar at the start of the UTC trading day × (1 + stop increment)
Calculation: Long target = entry price + (entry price − long stop) × risk-reward ratio
Calculation: Short target = entry price − (short stop − entry price) × risk-reward ratio
Exit: Long, low ≤ long stop OR high ≥ long target OR elapsed time since entry = configured timed-exit threshold
Exit: Short, high ≥ short stop OR low ≤ short target OR elapsed time since entry = configured timed-exit threshold