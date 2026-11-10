Calculation: Pivot lookback = a short lookback derived from sensitivity; optionally multiply it by the smoothed ratio of ATR to its longer-period SMA raised to a power, round it, and apply a minimum. Use successively longer multiples for the medium- and long-term lookbacks.
Calculation: Confirmed pivot = a high or low at the center of a window with the current pivot lookback on each side; detect it when the right side completes. Calculate separate short-, medium-, and long-term pivots.
Calculation: Pivot confidence = the average stored score of the nearest k previous pivots of the same term and high/low type, ranked by Manhattan distance between their pivot-bar relative ATR and relative volume. Relative ATR is ATR divided by its longer-period SMA; relative volume is volume divided by its SMA. Store every detected pivot with score 1, retaining a limited history. If the history contains no more than k pivots, confidence is 0.5.
Calculation: Active high or low = the latest confirmed pivot of the corresponding term and type whose confidence meets the threshold; replace it when another qualifying pivot appears and remove it when close breaks it.
Calculation: Selected high and low = the latest confirmed high and low pivots of the selected term, regardless of confidence. The term may be selected explicitly or automatically as the longest enabled term.
Calculation: Bias factor = (close - selected low) / max(small positive constant, selected high - selected low).
Calculation: Cumulative delta = sum of volume on bars with close above open minus volume on all other bars, starting on the confirmation bar of the latest qualifying active high or low of the selected term and ending when that level is broken or replaced.
Long: A high pivot is confirmed AND its confidence is at least the threshold.
Short: A low pivot is confirmed AND its confidence is at least the threshold.
Long: Close is above an active high.
Short: Close is below an active low.
Long: Selected high and low exist AND close is at least selected low AND (bias factor is above its midpoint OR close is above selected high).
Short: Selected high and low exist AND (close is below selected low OR (close is at most selected high AND bias factor is below its midpoint)).
Long: Cumulative delta is at least zero.
Short: Cumulative delta is below zero.