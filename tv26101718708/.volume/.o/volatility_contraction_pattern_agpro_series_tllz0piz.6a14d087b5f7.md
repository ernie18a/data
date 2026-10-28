Calculation: Confirmed swing highs and lows = local highs and lows confirmed using the same configurable number of bars on each side; retain alternating swings, replacing the latest same-type swing only when a more extreme one is confirmed, and retain only a configurable number of swings.
Calculation: Pivot = price of the most recent confirmed swing high.
Calculation: Base low = lowest price among the latest base swings, where the number of swings is the smaller of the configured base window and the larger of 3 and contraction count + 1; contraction count starts at 1 and increases for each successive older swing leg whose absolute price change exceeds the next newer leg, up to 4.
Calculation: Invalidation price = most recent confirmed swing low if below close; otherwise base low if below close; otherwise the lowest low of the last 50 bars.
Calculation: A base exists = at least 3 confirmed swings and a defined pivot, latest swing low, base high, and base low.
Long: A base exists AND close > pivot
Short: A base exists AND close < invalidation price