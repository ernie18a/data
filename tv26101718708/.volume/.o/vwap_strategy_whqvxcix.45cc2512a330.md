Calculation: NYSE-session VWAP = cumulative volume-weighted average of HLC3 during the current regular session
Calculation: 18:00-to-16:00 anchored VWAP = cumulative volume-weighted average of HLC3 during the current session anchored at 18:00
Long: EMA(5) crosses above EMA(13)
Short: EMA(5) crosses below EMA(13)
Long: During the regular session, price crosses above the NYSE-session VWAP (by close crossing or by a bar spanning the VWAP and closing above it after the prior close was below it)
Short: During the regular session, price crosses below the NYSE-session VWAP (by close crossing or by a bar spanning the VWAP and closing below it after the prior close was above it)
Long: The NYSE-session VWAP crosses above the 18:00-to-16:00 anchored VWAP
Short: The NYSE-session VWAP crosses below the 18:00-to-16:00 anchored VWAP
Long: During the trade window, a long reclaim has occurred since the regular-session start without two consecutive closes below the NYSE-session VWAP; EMA(5) > EMA(8) > EMA(13); all three EMAs are rising; the bar low <= NYSE-session VWAP + touch buffer; close > NYSE-session VWAP; and volume > prior-bar volume when volume confirmation is enabled
Short: During the trade window, a short reclaim has occurred since the regular-session start without two consecutive closes above the NYSE-session VWAP; EMA(5) < EMA(8) < EMA(13); all three EMAs are falling; the bar high >= NYSE-session VWAP - touch buffer; close < NYSE-session VWAP; and volume > prior-bar volume when volume confirmation is enabled
Long: While flat and within the trade window, price reaches the pending long setup bar high plus one tick; its stop distance from the setup bar low minus the stop buffer is within the configured maximum; the setup remains valid (no two consecutive closes below the NYSE-session VWAP, bullish EMA alignment, reclaim state, and trade window)
Short: While flat and within the trade window, price reaches the pending short setup bar low minus one tick; its stop distance from the setup bar high plus the stop buffer is within the configured maximum; the setup remains valid (no two consecutive closes above the NYSE-session VWAP, bearish EMA alignment, reclaim state, and trade window)
Exit: Long, price <= setup bar low minus stop buffer OR price >= entry price plus take-profit distance
Exit: Short, price >= setup bar high plus stop buffer OR price <= entry price minus take-profit distance