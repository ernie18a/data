Calculation: Successive up-ticks = consecutive current-candle tick price increases versus the preceding tick; reset to zero on any tick that does not increase
Calculation: Successive down-ticks = consecutive current-candle tick price decreases versus the preceding tick; reset to zero on any tick that does not decrease
Calculation: Tick number = ordinal of the current tick update within the current candle
Long: Position is flat AND current price > current candle open AND successive up-ticks = entry tick threshold AND (start-only counting is disabled OR tick number = entry tick threshold)
Short: Position is flat AND current price < current candle open AND successive down-ticks = entry tick threshold AND (start-only counting is disabled OR tick number = entry tick threshold)
Exit: Long, successive down-ticks = exit tick threshold AND (same-candle exits are enabled OR current candle is later than the entry candle)
Exit: Short, successive up-ticks = exit tick threshold AND (same-candle exits are enabled OR current candle is later than the entry candle)