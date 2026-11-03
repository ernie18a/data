Calculation: Standard range high/low = highest high / lowest low over the longer lookback of completed bars before the current bar.
Calculation: Tight shelf high/low = highest high / lowest low over the shorter lookback of completed bars before the current bar.
Calculation: Range width % = 100 × (range high − range low) / ((range high + range low) / 2).
Calculation: Close containment % = 100 × the fraction of closes in the range lookback that lie between its high and low.
Calculation: Shelf upper-half % = 100 × the fraction of closes in the shelf lookback that are at or above its midpoint.
Calculation: Prior advance % = 100 × (range high − lowest low over the prior-move lookback immediately before the range) / that lowest low.
Calculation: ADR % = the moving average of 100 × (high − low) / close over its lookback.
Calculation: A standard range qualifies when its close containment meets the minimum, its width % is at most ADR % × the standard-range width limit, the prior close is above the 200-period SMA when that filter is enabled, and either the prior close is at or above the 20-period EMA or the 10-period EMA is at or above the 20-period EMA; when enabled, also require prior advance % to meet its minimum, the average volume during the range to be at most the prior average volume × its limit, and prior RSI to be within its minimum and maximum.
Calculation: A tight shelf qualifies under the same conditions as a standard range, using the shelf lookback and its own width limit, and additionally requiring shelf upper-half % to meet its minimum.
Calculation: Active range = qualifying tight shelf if one exists; otherwise qualifying standard range if one exists; otherwise none.
Long: An active range exists AND current close > active range high.
Short: An active range exists AND current close < active range low.