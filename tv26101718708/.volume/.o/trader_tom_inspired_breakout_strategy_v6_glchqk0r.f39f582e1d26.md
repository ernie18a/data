Calculation: Breakout level = highest high of the configured number of completed bars, excluding the current bar; in all-time-high mode, highest high of the preceding 5,000 bars, excluding the current bar
Calculation: Initial stop = entry price − ATR × stop multiplier, using ATR on the entry bar
Calculation: Active long stop = max(initial stop, close − ATR × trailing multiplier) when trailing stop is enabled, otherwise initial stop; if close < short EMA and EMA-break exit is enabled, raise the stop to at least close
Calculation: Long target = entry price + (entry price − initial stop) × reward multiple
Calculation: Partial target = entry price + (entry price − initial stop) × partial-profit multiple
Long: (close > breakout level when close confirmation is enabled, otherwise high > breakout level) AND (trend filter disabled OR (close > short EMA AND short EMA > long EMA)) AND (volume filter disabled OR volume > volume SMA × volume multiplier) AND position is flat
Exit: long, low <= active long stop OR high >= long target OR (partial-profit exit enabled AND high >= partial target)