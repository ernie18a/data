Calculation: Prior range high/low = highest high/lowest low over the lookback bars before the current bar.
Calculation: Target midpoint = prior range high/low plus/minus the mean of (prior range width × range projection multiple) and (current ATR × ATR projection multiple), with the distance clamped between minimum and maximum ATR multiples; add for long, subtract for short.
Calculation: Invalidation shelf = lowest low for long or highest high for short over the lookback bars before the plan starts.
Long: Close > prior range high + current ATR × breakout buffer, and the new-plan cooldown has elapsed, and no active plan exists or the active plan is resolved or has the opposite side.
Short: Close < prior range low − current ATR × breakout buffer, and the new-plan cooldown has elapsed, and no active plan exists or the active plan is resolved or has the opposite side.
Exit: Long, close ≥ target midpoint − target band half-width OR close < invalidation shelf − plan-start ATR × invalidation buffer.
Exit: Short, close ≤ target midpoint + target band half-width OR close > invalidation shelf + plan-start ATR × invalidation buffer.