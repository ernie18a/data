Calculation: Confirmed swing high = the high of a bar whose high is at least every high in an equal-length window on each side; it becomes available after the right-hand window completes.
Calculation: Confirmed swing low = the low of a bar whose low is at most every low in an equal-length window on each side; it becomes available after the right-hand window completes.
Long: A swing high is confirmed AND its high > the preceding confirmed swing high.
Long: A swing low is confirmed AND its low > the preceding confirmed swing low.
Short: A swing high is confirmed AND its high <= the preceding confirmed swing high.
Short: A swing low is confirmed AND its low <= the preceding confirmed swing low.
Long: Close > the latest confirmed swing high AND (there is no preceding confirmed swing high OR the latest confirmed swing high <= the preceding confirmed swing high).
Short: Close < the latest confirmed swing low AND (there is no preceding confirmed swing low OR the latest confirmed swing low > the preceding confirmed swing low).
Long: High - low > a multiplier times the median of high - low over a lookback including the current bar AND abs(close - open) >= a fraction of high - low AND close > open.
Short: High - low > a multiplier times the median of high - low over a lookback including the current bar AND abs(close - open) >= a fraction of high - low AND close <= open.