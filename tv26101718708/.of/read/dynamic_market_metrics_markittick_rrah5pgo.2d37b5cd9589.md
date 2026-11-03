Calculation: For bar t, range average R[t] = SMA of true range through bar t-1, using the same lookback as MFI.
Calculation: Trend anchor A[t] = max(low[t-1] - multiplier × R[t], A[t-1]) if MFI of typical price at t-1 is at least its midpoint; otherwise min(high[t-1] + multiplier × R[t], A[t-1]). Replace an unavailable previous anchor with zero.
Calculation: Raw bullish event B[t] = (A[t-1] > A[t-3] AND A[t-2] <= A[t-4]) OR (breakout override enabled AND abs(close[t-1] - close[t-2]) > sensitivity × R[t-1] AND close[t-1] > A[t-1] AND close[t-2] <= A[t-2]). Replace unavailable anchors in the non-strict comparison with zero.
Calculation: Raw bearish event S[t] = (A[t-1] < A[t-3] AND A[t-2] >= A[t-4]) OR (breakout override enabled AND abs(close[t-1] - close[t-2]) > sensitivity × R[t-1] AND close[t-1] < A[t-1] AND close[t-2] >= A[t-2]). Replace unavailable anchors in the non-strict comparison with zero.
Calculation: Bullish age and bearish age start at zero and, on each bar, reset to zero if the respective raw event occurred on the preceding bar; otherwise increment by one.
Calculation: Direction starts bullish. On each bar set it bullish if A[t-1] > A[t-3], bearish if A[t-1] < A[t-3], and otherwise retain its previous value. Then set it bullish on the bullish breakout condition or, otherwise, bearish on the bearish breakout condition.
Calculation: Higher-timeframe calculations apply the same definitions to aggregated higher-timeframe bars and use the last completed higher-timeframe bar. A higher-timeframe event is emitted on the chart bar immediately after the first chart bar of a new higher-timeframe bar.
Long: Direction = bullish.
Short: Direction = bearish.
Long: B[t] = true AND bullish age > bearish age.
Short: S[t] = true AND bearish age > bullish age.
Long: Last completed higher-timeframe direction = bullish.
Short: Last completed higher-timeframe direction = bearish.
Long: Higher-timeframe event emitted AND last completed higher-timeframe B = true AND its bullish age > its bearish age.
Short: Higher-timeframe event emitted AND last completed higher-timeframe S = true AND its bearish age > its bullish age.
Exit: long, bullish age < bearish age AND close[t-1] < A[t-1].
Exit: short, bearish age < bullish age AND close[t-1] > A[t-1].