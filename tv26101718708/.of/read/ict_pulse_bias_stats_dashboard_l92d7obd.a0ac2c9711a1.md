Calculation: Range midpoint = (high + low) / 2 of the last completed bar of a higher timeframe; use three higher timeframes ordered from shorter to longer.
Calculation: Session midpoint = (highest high + lowest low) / 2 over chart bars in the currently active session through the current bar; if sessions overlap, select the first active session in a fixed priority order.
Calculation: A session low or high is taken if, since that session most recently ended, any chart bar low was below its completed session low or any chart bar high was above its completed session high, respectively. Reset each session's taken status when that session ends, then evaluate the current bar against the newly completed session range.
Calculation: Bullish score = the count of the three higher timeframes whose last completed bar has high > low and whose range midpoint is <= close, plus 1 if any session low is taken, plus 1 if close >= session midpoint.
Calculation: Bearish score = the count of the three higher timeframes whose last completed bar has high > low and whose range midpoint is > close, plus 1 if any session high is taken, plus 1 if close < session midpoint.
Long: Close >= range midpoint for any of the three higher timeframes.
Short: Close < range midpoint for any of the three higher timeframes.
Long: Bullish score > bearish score.
Short: Bearish score > bullish score.