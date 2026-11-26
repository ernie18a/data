Calculation: Asia session high = maximum high from the current Asia session start through the current bar, retained until the next Asia session starts.
Calculation: Asia session low = minimum low from the current Asia session start through the current bar, retained until the next Asia session starts.
Calculation: London session high = maximum high from the current London session start through the current bar, retained until the next London session starts.
Calculation: London session low = minimum low from the current London session start through the current bar, retained until the next London session starts.
Calculation: overnight session high = maximum high from the current overnight session start through the current bar, retained until the next overnight session starts.
Calculation: overnight session low = minimum low from the current overnight session start through the current bar, retained until the next overnight session starts.
Calculation: latest active demand zone = bounds [low[1], max(open[1], close[1])] from the most recent bar where the zone option is enabled, close > open, high - low > SMA(high - low, average-range lookback) × impulse-strength multiplier, close - open > (high - low) × body-fraction parameter, and abs(close[1] - open[1]) < SMA(high - low, average-range lookback) × base-size multiplier; remove a zone when close falls below its lower bound and retain at most the maximum-zones-per-side parameter, discarding the oldest first.
Calculation: latest active supply zone = bounds [min(open[1], close[1]), high[1]] from the most recent bar where the zone option is enabled, close < open, high - low > SMA(high - low, average-range lookback) × impulse-strength multiplier, open - close > (high - low) × body-fraction parameter, and abs(close[1] - open[1]) < SMA(high - low, average-range lookback) × base-size multiplier; remove a zone when close rises above its upper bound and retain at most the maximum-zones-per-side parameter, discarding the oldest first.
Long: close crosses above London session high.
Short: close crosses below London session low.
Long: close crosses above Asia session high.
Short: close crosses below Asia session low.
Long: close crosses above overnight session high.
Short: close crosses below overnight session low.
Long: zone option is enabled AND a latest active demand zone exists AND low <= its upper bound AND high >= its lower bound.
Short: zone option is enabled AND a latest active supply zone exists AND high >= its lower bound AND low <= its upper bound.