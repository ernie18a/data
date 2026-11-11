Calculation: Confirmed pivot high = the high of a bar whose high is at least as high as each high in an equal number of preceding bars and strictly higher than each high in the same number of subsequent bars; it is confirmed on the last subsequent bar.
Calculation: Confirmed pivot low = the low of a bar whose low is at most as low as each low in an equal number of preceding bars and strictly lower than each low in the same number of subsequent bars; it is confirmed on the last subsequent bar. The number of bars on each side is the same as for a confirmed pivot high.
Long: close >= open
Long: close > EMA of close
Long: a pivot high is confirmed AND (no previous confirmed pivot high exists OR the pivot high > the previous confirmed pivot high)
Long: a pivot low is confirmed AND (no previous confirmed pivot low exists OR the pivot low > the previous confirmed pivot low)
Short: close < open
Short: close < EMA of close
Short: a pivot high is confirmed AND a previous confirmed pivot high exists AND the pivot high <= the previous confirmed pivot high
Short: a pivot low is confirmed AND a previous confirmed pivot low exists AND the pivot low <= the previous confirmed pivot low