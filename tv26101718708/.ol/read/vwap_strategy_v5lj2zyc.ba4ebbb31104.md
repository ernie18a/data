Calculation: NY-session VWAP = cumulative (HLC3 × volume) divided by cumulative volume, reset at the start of the NY regular session.
Calculation: Long reclaim state = set when a regular-session close is above NY-session VWAP and either the prior close was also above it or the prior close was at or below the prior bar's VWAP; reset at session start, after two consecutive closes below VWAP, or after a later close fails to remain above VWAP for two consecutive bars.
Calculation: Short reclaim state = set when a regular-session close is below NY-session VWAP and either the prior close was also below it or the prior close was at or above the prior bar's VWAP; reset at session start, after two consecutive closes above VWAP, or after a later close fails to remain below VWAP for two consecutive bars.
Long: EMA(5) > EMA(8) > EMA(13) AND each EMA is above its prior-bar value AND long reclaim state is set AND low <= NY-session VWAP + touch buffer AND close > NY-session VWAP AND volume > prior-bar volume AND time is within the trade window AND NY-session VWAP cross count < limit
Short: EMA(5) < EMA(8) < EMA(13) AND each EMA is below its prior-bar value AND short reclaim state is set AND high >= NY-session VWAP - touch buffer AND close < NY-session VWAP AND volume > prior-bar volume AND time is within the trade window AND NY-session VWAP cross count < limit
Long: pending long setup AND high >= setup-bar high + one tick AND setup-bar high + one tick > setup-bar low - stop buffer AND risk from entry stop to stop price <= maximum stop
Short: pending short setup AND low <= setup-bar low - one tick AND setup-bar high + stop buffer > setup-bar low - one tick AND risk from stop price to entry stop <= maximum stop
Long: EMA(5) crosses above EMA(13)
Short: EMA(5) crosses below EMA(13)
Long: during the regular session, close crosses above NY-session VWAP (or, in wick mode, the bar spans VWAP, prior close is below prior VWAP, and current close is above VWAP)
Short: during the regular session, close crosses below NY-session VWAP (or, in wick mode, the bar spans VWAP, prior close is above prior VWAP, and current close is below VWAP)
Long: NY-session VWAP crosses above 18:00-to-16:00 anchored VWAP during the regular session
Short: NY-session VWAP crosses below 18:00-to-16:00 anchored VWAP during the regular session
Exit: long, low <= setup-bar low - stop buffer OR high >= entry price + profit target
Exit: short, high >= setup-bar high + stop buffer OR low <= entry price - profit target