Calculation: NY-session VWAP = cumulative sum of (high + low + close) / 3 × volume since the NY session open, divided by cumulative volume
Calculation: Overnight-session VWAP = cumulative sum of (high + low + close) / 3 × volume since the overnight session open, divided by cumulative volume
Calculation: Long setup remains reclaimed after a close above NY-session VWAP until two consecutive closes below it; short setup remains reclaimed after a close below it until two consecutive closes above it
Long: during the regular session, EMA(5) crosses above EMA(13)
Long: during the regular session, close crosses above NY-session VWAP, or low reaches NY-session VWAP and close finishes above it after the prior close was below it
Long: during the regular session, NY-session VWAP crosses above overnight-session VWAP
Long: during the trade window, after a long reclaim, EMA(5) > EMA(8) > EMA(13), each EMA is rising, low <= NY-session VWAP + touch buffer, close > NY-session VWAP, volume > prior bar volume if volume confirmation is enabled, NY-session VWAP cross count is below its limit, and high > setup-bar high + one tick with risk to setup-bar low minus stop buffer within the maximum stop
Short: during the regular session, EMA(5) crosses below EMA(13)
Short: during the regular session, close crosses below NY-session VWAP, or high reaches NY-session VWAP and close finishes below it after the prior close was above it
Short: during the regular session, NY-session VWAP crosses below overnight-session VWAP
Short: during the trade window, after a short reclaim, EMA(5) < EMA(8) < EMA(13), each EMA is falling, high >= NY-session VWAP - touch buffer, close < NY-session VWAP, volume > prior bar volume if volume confirmation is enabled, NY-session VWAP cross count is below its limit, and low < setup-bar low - one tick with risk to setup-bar high plus stop buffer within the maximum stop
Exit: long, low <= setup-bar low - stop buffer OR high >= entry price + profit target
Exit: short, high >= setup-bar high + stop buffer OR low <= entry price - profit target