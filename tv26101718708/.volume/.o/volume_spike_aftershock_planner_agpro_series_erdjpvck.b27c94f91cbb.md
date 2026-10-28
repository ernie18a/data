Calculation: Relative volume = current volume / simple moving average of volume over the preceding lookback, including the current bar.
Calculation: Range ratio = (high − low) / simple moving average of (high − low) over the preceding lookback, including the current bar.
Calculation: Body ratio = abs(close − open) / max(high − low, minimum tick size).
Calculation: Close location = (close − low) / max(high − low, minimum tick size).
Calculation: Bull spike = relative volume ≥ threshold AND range ratio ≥ threshold AND body ratio ≥ threshold AND close > open AND close location ≥ 0.60.
Calculation: Bear spike = relative volume ≥ threshold AND range ratio ≥ threshold AND body ratio ≥ threshold AND close < open AND close location ≤ 0.40.
Calculation: New spike = bull spike OR bear spike, and neither was true on the previous bar.
Calculation: Spike anchor = close of the new spike bar; spike high and spike low = its high and low.
Calculation: ATR = average true range on the current chart timeframe. Use max(ATR, minimum tick size) as safe ATR.
Calculation: Spike depth = min((spike high − spike low) × 0.38, safe ATR × band-depth parameter).
Calculation: Bull hold rail = spike anchor − spike depth + safe ATR × hold-buffer parameter; bear hold rail = spike anchor + spike depth − safe ATR × hold-buffer parameter.
Calculation: Bull absorption rail = spike anchor − safe ATR × absorption-buffer parameter; bear absorption rail = spike anchor + safe ATR × absorption-buffer parameter.
Calculation: Bull failure rail = spike low − safe ATR × failure-buffer parameter; bear failure rail = spike high + safe ATR × failure-buffer parameter.
Calculation: Spike age = current bar index − spike bar index. Spike remains active through the maximum age; it expires when age exceeds that limit.
Long: Bull spike AND neither bull nor bear spike was true on the previous bar.
Short: Bear spike AND neither bull nor bear spike was true on the previous bar.
Exit: Long, an active bullish spike is absorbed (close < bull absorption rail) OR fails (close < bull failure rail) OR expires.
Exit: Short, an active bearish spike is absorbed (close > bear absorption rail) OR fails (close > bear failure rail) OR expires.