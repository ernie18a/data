Calculation: Cumulative Volume Delta = cumulative sum of volume when close > open and negative volume otherwise, on chart bars, resetting at each T1 boundary
Long: On each chart bar, current still-forming T1 close >= T1 open
Short: On each chart bar, current still-forming T1 close < T1 open
Long: T1 close >= T1 open on each of the up to (dashboard-history parameter - 1) most recent completed T1 bars
Short: T1 close < T1 open on each of the up to (dashboard-history parameter - 1) most recent completed T1 bars
Long: Mean of +1 for each of the up to (dashboard-history parameter - 1) most recent completed T1 bars with close >= open, and -1 otherwise, is > 0
Short: Mean of +1 for each of the up to (dashboard-history parameter - 1) most recent completed T1 bars with close >= open, and -1 otherwise, is <= 0
Long: Last Cumulative Volume Delta value in the current still-forming T1 is >= 0 AND at least two chart bars have occurred in that T1
Short: Last Cumulative Volume Delta value in the current still-forming T1 is < 0 AND at least two chart bars have occurred in that T1
Long: On a chart bar in the current still-forming T1, close > open AND volume > Standard Deviation of Cumulative Volume Delta values on chart bars in that T1 * flush-threshold AND at least two chart bars have occurred in that T1
Short: On a chart bar in the current still-forming T1, close <= open AND volume > Standard Deviation of Cumulative Volume Delta values on chart bars in that T1 * flush-threshold AND at least two chart bars have occurred in that T1