Calculation: Vector climax = volume >= vector climax multiplier × SMA(volume, vector lookback) OR volume × (high - low) = highest(volume × (high - low), vector lookback)
Calculation: Vector active = volume >= vector active multiplier × SMA(volume, vector lookback) AND vector climax = false
Calculation: Long stop = entry price - entry-bar ATR × stop multiplier OR entry-bar lowest low over the swing lookback - entry-bar ATR × swing buffer
Calculation: Short stop = entry price + entry-bar ATR × stop multiplier OR entry-bar highest high over the swing lookback + entry-bar ATR × swing buffer
Calculation: Long target = entry price + (entry price - long stop) × reward-to-risk multiplier
Calculation: Short target = entry price - (short stop - entry price) × reward-to-risk multiplier
Long: vector climax = true AND close >= open
Long: vector active = true AND close >= open
Short: vector climax = true AND close < open
Short: vector active = true AND close < open
Exit: long, low <= long stop OR high >= long target
Exit: short, high >= short stop OR low <= short target
Incomplete: The regime, reversal, liquidity-reclaim, and opposing-reversal exit decisions require additional stateful calculations that are not specified here.