Calculation: Pivot high = a bar whose high is higher than the highs of the configured number of bars before and after it; confirmed after those later bars complete.
Calculation: Pivot low = a bar whose low is lower than the lows of the configured number of bars before and after it; confirmed after those later bars complete.
Calculation: Deduplication threshold = configured ATR multiple, percentage of current close, or fixed point distance.
Long: Pivot low is confirmed AND (no previous major swing low OR absolute difference from the previous major swing low ≥ deduplication threshold)
Short: Pivot high is confirmed AND (no previous major swing high OR absolute difference from the previous major swing high ≥ deduplication threshold)