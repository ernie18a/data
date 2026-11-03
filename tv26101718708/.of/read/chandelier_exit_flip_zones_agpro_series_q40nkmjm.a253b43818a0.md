Calculation: Chandelier stops = On each chart bar, raw long stop is the highest high over the structure lookback minus ATR multiplied by a stop-distance multiplier; raw short stop is the lowest low over the same lookback plus ATR multiplied by the same multiplier. For each stop, use its previous value, or its current raw value if the previous value is unavailable. If the previous close is above the prior long stop, the current long stop is the maximum of the raw and prior long stops; otherwise it is the raw long stop. If the previous close is below the prior short stop, the current short stop is the minimum of the raw and prior short stops; otherwise it is the raw short stop.
Calculation: Trail side = Initialize long. On each bar, set long if close is above the prior short stop; otherwise set short if close is below the prior long stop; otherwise retain the previous side. Use the current raw stop when its prior stop is unavailable.
Calculation: Active trail distance = Absolute difference between close and the current stop for the trail side, divided by ATR; undefined when ATR is not positive.
Long: Trail side is long AND previous trail side is short
Long: Trail side is long
Short: Trail side is short AND previous trail side is long
Short: Trail side is short
Exit: long, trail side is long AND active trail distance is at or below the exit-watch threshold
Exit: short, trail side is short AND active trail distance is at or below the exit-watch threshold