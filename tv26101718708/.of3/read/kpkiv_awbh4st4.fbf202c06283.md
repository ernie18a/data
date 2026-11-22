Calculation: Intrinsic value = max(0, if option type is Call then spot high − strike price else strike price − spot low)
Calculation: Level(n) = intrinsic value + step size × n, for positive n through the level-count parameter when the multiplier permits that level
Long: volume ≥ SMA(volume, lookback) × volume-threshold percentage / 100 AND close ≥ open
Short: volume ≥ SMA(volume, lookback) × volume-threshold percentage / 100 AND close < open
Long: entry toggle enabled AND close crosses above an available Level(n) whose next level is also available
Exit: long, target-hit toggle enabled AND high ≥ the next level above the crossed level selected at the current tracked entry
Exit: long, stop-hit toggle enabled AND close ≤ the low of the bar immediately before the current tracked entry AND (target-hit toggle disabled OR high < the next level above the crossed level selected at the current tracked entry)
Calculation: call premium level n = max(0, configured spot high - option strike price) + premium step size × n, for n from 1 through 7
Calculation: put premium level n = max(0, option strike price - configured spot low) + premium step size × n, for n from 1 through 7
Option: buy call, call selected AND entry display enabled AND close crosses above call premium level n for some n from 1 through 6 AND configured level count >= n + 1
Option: buy put, put selected AND entry display enabled AND close crosses above put premium level n for some n from 1 through 6 AND configured level count >= n + 1
Exit: long, target-hit marking enabled AND high >= the next premium level above the lowest premium level crossed upward by the entry close
Exit: long, stop-loss marking enabled AND close <= the low of the bar before entry AND (target-hit marking disabled OR high < the next premium level above the lowest premium level crossed upward by the entry close)