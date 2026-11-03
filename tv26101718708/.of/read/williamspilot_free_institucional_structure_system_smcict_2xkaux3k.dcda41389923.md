Calculation: Range high and low = either the highest high and lowest low over a lookback including the current bar, or the running high and low of the still-forming higher-timeframe bar.
Calculation: Premium threshold = range low plus an upper fraction of the range; discount threshold = range low plus a lower fraction of the range.
Calculation: Confirmed swing high and swing low = pivot high and pivot low using equal numbers of bars before and after the pivot; recognize each only when the bars after it have completed.
Calculation: Upward break = close crosses above the latest confirmed swing high as known before the current bar, and that swing high has not previously produced an upward break. A newly confirmed swing high becomes eligible after the current bar's break check.
Calculation: Downward break = close crosses below the latest confirmed swing low as known before the current bar, and that swing low has not previously produced a downward break. A newly confirmed swing low becomes eligible after the current bar's break check.
Calculation: Structure direction = direction of the most recent upward or downward break; initially neutral, and downward takes precedence if both breaks occur on the same bar.
Long: Close <= discount threshold AND close < premium threshold.
Short: Close >= premium threshold.
Long: A swing high is confirmed AND its price > the preceding confirmed swing high.
Short: A swing high is confirmed AND its price <= the preceding confirmed swing high.
Long: A swing low is confirmed AND its price > the preceding confirmed swing low.
Short: A swing low is confirmed AND its price <= the preceding confirmed swing low.
Long: Upward break.
Short: Downward break.
Long: Structure direction is upward.
Short: Structure direction is downward.
Long: Low > high two bars earlier.
Short: High < low two bars earlier.