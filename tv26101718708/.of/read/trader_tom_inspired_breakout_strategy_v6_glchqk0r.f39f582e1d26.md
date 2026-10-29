Calculation: Breakout level = highest high over the selected lookback or all-time window, excluding the current bar
Calculation: Initial stop = entry price − ATR × stop multiplier
Calculation: Trade risk = entry price − initial stop
Calculation: Active stop = the higher of the initial stop and (if trailing is enabled) current close − ATR × trailing multiplier; if the EMA exit filter is enabled and close is below the short-period EMA, use the higher of that stop and current close
Calculation: Full target = entry price + trade risk × reward multiple
Calculation: Partial target = entry price + trade risk × partial-profit multiple
Long: position is flat AND (close > breakout level when close confirmation is enabled, otherwise high > breakout level) AND (trend filter is disabled OR (close > short-period EMA AND short-period EMA > longer-period EMA)) AND (volume filter is disabled OR volume > volume moving average × volume multiplier)
Exit: long, low <= active stop OR high >= full target
Exit: long, high >= partial target