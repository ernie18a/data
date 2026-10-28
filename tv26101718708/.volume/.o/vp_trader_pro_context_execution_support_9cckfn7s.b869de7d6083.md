Calculation: Active volume profile = distribute each bar’s volume uniformly across price bins spanning its low to high over the configured profile range, including the current bar
Calculation: POC = price bin with the greatest profile volume
Calculation: Value Area = contiguous price bins around the POC containing the configured fraction of profile volume; VAH and VAL are its upper and lower boundaries
Calculation: Profile shift = (current POC − reference POC) / current Value Area width
Calculation: Value Area overlap = intersection width of current and reference Value Areas / their union width
Calculation: Session cumulative delta = sum of each in-session bar’s volume, positive when close > open and negative when close < open
Calculation: Price pivot high/low = a high/low greater/less than the highs/lows of the configured number of bars on both sides; confirmed after the bars on the right complete
Long: close is above VAH for the configured consecutive confirmation count
Long: close is below VAL after at least one but fewer than the configured consecutive confirmation count of closes below VAL
Long: previous close was below VAL and current close is within [VAL, VAH], after price was outside value
Long: close > VAH
Long: close < VAL and the latest confirmed price pivot low is lower than the preceding confirmed pivot low while session cumulative delta at the latest pivot is greater than at the preceding pivot
Long: signal bias > 0
Long: signal regime is bullish breakout or bullish bias
Long: ADS bias > 10
Long: ADS regime is BREAKOUT_UP, TREND_UP, or BULL_BIAS
Short: close is below VAL for the configured consecutive confirmation count
Short: close is above VAH after at least one but fewer than the configured consecutive confirmation count of closes above VAH
Short: previous close was above VAH and current close is within [VAL, VAH], after price was outside value
Short: close < VAL
Short: close > VAH and the latest confirmed price pivot high is higher than the preceding confirmed pivot high while session cumulative delta at the latest pivot is lower than at the preceding pivot
Short: signal bias < 0
Short: signal regime is bearish breakout or bearish bias
Short: ADS bias < -10
Short: ADS regime is BREAKOUT_DOWN, TREND_DOWN, or BEAR_BIAS