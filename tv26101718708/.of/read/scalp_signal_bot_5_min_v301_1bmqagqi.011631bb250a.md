Calculation: Confirmed swing high = the highest swing-source value over pivot-length bars before and after the candidate bar; it becomes available pivot-length bars later. Swing source is high or max(open, close).
Calculation: Confirmed swing low = the lowest swing-source value over pivot-length bars before and after the candidate bar; it becomes available pivot-length bars later. Swing source is low or min(open, close).
Calculation: Sweep buffer = ATR × buffer multiplier, or a configurable fixed tick buffer.
Calculation: Lowest-low sweep = current swing-source low < the prior bar's lowest swing-source low over the sweep lookback.
Calculation: Highest-high sweep = current swing-source high > the prior bar's highest swing-source high over the sweep lookback.
Calculation: Low-sweep reclaim = within the maximum sweep age, close > latest lowest-low sweep price + sweep buffer; either on the sweep bar or after the prior close was at or below that level.
Calculation: High-sweep reclaim = within the maximum sweep age, close < latest highest-high sweep price − sweep buffer; either on the sweep bar or after the prior close was at or above that level.
Long: Lowest-low sweep OR low-sweep reclaim OR (close > latest confirmed swing high AND (sweep filter disabled OR low-sweep reclaim) AND (trend mode is CHOP OR longs are enabled in TREND mode and close > trend EMA) AND sweep delay has elapsed or is disabled AND long cluster block is disabled or absent AND long reclaim suppression is absent AND volume filter is disabled or passes).
Short: Highest-high sweep OR high-sweep reclaim OR (close < latest confirmed swing low AND (trend mode is CHOP OR shorts are enabled in TREND mode and close < trend EMA) AND sweep delay has elapsed or is disabled AND short cluster block is disabled or absent AND short reclaim suppression is absent AND volume filter is disabled or passes).
Exit: Long, low ≤ locked stop OR high ≥ locked target.
Exit: Short, high ≥ locked stop OR low ≤ locked target.