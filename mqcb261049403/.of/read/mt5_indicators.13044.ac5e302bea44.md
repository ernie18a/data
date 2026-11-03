Calculation: Lower level = highest high over the range lookback ending at the configured bar offset minus an ATR multiple.
Calculation: Upper level = lowest low over the same range lookback and offset plus the same ATR multiple.
Calculation: Direction = initially nonnegative; on each completed calculation-timeframe bar, change to negative if previously nonnegative and close < lower level, or to positive if previously negative and close > upper level; otherwise retain the previous direction.
Calculation: Level pair = if the previous direction is nonnegative and close >= lower level, or the previous direction is negative and close > upper level, set first level = lower level and second level = upper level; otherwise set first level = upper level and second level = lower level. Evaluate on the chart timeframe or on a higher timeframe using the still-forming bar or a configured completed bar; use the previous completed calculation-timeframe bar for the previous level pair.
Calculation: Bullish event = previous second level <= previous first level AND current second level > current first level.
Calculation: Bearish event = previous second level >= previous first level AND current second level < current first level.
Calculation: Marked trend = direction of the most recent bullish or bearish event; if both occur together, use bearish.
Long: Marked trend = bullish.
Short: Marked trend = bearish.