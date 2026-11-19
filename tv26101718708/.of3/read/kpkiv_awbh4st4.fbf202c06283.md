Calculation: Intrinsic value = max(0, if option type is Call then spot high − strike price else strike price − spot low)
Calculation: Level(n) = intrinsic value + step size × n, for positive n through the level-count parameter when the multiplier permits that level
Long: volume ≥ SMA(volume, lookback) × volume-threshold percentage / 100 AND close ≥ open
Short: volume ≥ SMA(volume, lookback) × volume-threshold percentage / 100 AND close < open
Long: entry toggle enabled AND close crosses above an available Level(n) whose next level is also available
Exit: long, target-hit toggle enabled AND high ≥ the next level above the crossed level selected at the current tracked entry
Exit: long, stop-hit toggle enabled AND close ≤ the low of the bar immediately before the current tracked entry AND (target-hit toggle disabled OR high < the next level above the crossed level selected at the current tracked entry)