Calculation: Confirmed pivot high = a high greater than or equal to each high in a preceding swing-length window and strictly greater than each high in an equally long following window; available when the following window completes.
Calculation: Confirmed pivot low = a low less than or equal to each low in a preceding swing-length window and strictly less than each low in an equally long following window; available when the following window completes.
Calculation: Trend = initially undefined; set bullish when a confirmed pivot high is strictly above the previous confirmed pivot high, and bearish when a confirmed pivot low is strictly below the previous confirmed pivot low. Otherwise retain the previous trend. If both pivots are confirmed on the same bar, process the high first.
Long: Confirmed pivot high exists AND (previous confirmed pivot high does not exist OR confirmed pivot high > previous confirmed pivot high).
Long: Confirmed pivot low exists AND (previous confirmed pivot low does not exist OR confirmed pivot low >= previous confirmed pivot low).
Long: Trend = bullish.
Short: Confirmed pivot high exists AND confirmed pivot high <= previous confirmed pivot high.
Short: Confirmed pivot low exists AND confirmed pivot low < previous confirmed pivot low.
Short: Trend = bearish.