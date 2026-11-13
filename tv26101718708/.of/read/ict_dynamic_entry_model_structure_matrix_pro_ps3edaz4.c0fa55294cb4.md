Calculation: PivotHigh(n) = a bar whose high is the highest among the n bars before and the n bars after it; it is only known on the n-th bar after it, so act on the confirmation bar, not the pivot bar. PivotLow(n) is the mirror, using lows.
Calculation: MajorPivot = pivot with the longer lookback n_major; StructPivot = pivot with the shorter lookback n_struct (n_major > n_struct).
Calculation: MajorState = +1 if the most recently confirmed MajorPivot is a low, -1 if it is a high, 0 if none yet.
Calculation: StructHigh = value of the latest confirmed StructPivot high that has not yet been crossed by close; it is cleared once crossed and replaced when a new StructPivot high confirms. StructLow is the mirror for StructPivot lows.
Long: a MajorPivot low is confirmed on this bar (MajorState = +1)
Long: MajorState = +1 (trend state persists on every bar until a MajorPivot high confirms)
Long: close crosses above StructHigh (close > StructHigh AND previous close <= StructHigh)
Long: low > high of 2 bars earlier AND close > open
Short: a MajorPivot high is confirmed on this bar (MajorState = -1)
Short: MajorState = -1 (trend state persists on every bar until a MajorPivot low confirms)
Short: close crosses below StructLow (close < StructLow AND previous close >= StructLow)
Short: high < low of 2 bars earlier AND close < open