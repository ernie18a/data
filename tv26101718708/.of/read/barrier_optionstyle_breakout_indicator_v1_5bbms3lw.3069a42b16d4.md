Calculation: Upper barrier = selected manual upper level, the highest high of the preceding lookback bars, or the anchor price plus the configured sigma multiple of the expected move
Calculation: Lower barrier = selected manual lower level, the lowest low of the preceding lookback bars, or the anchor price minus the configured sigma multiple of the expected move
Calculation: Expected move = anchor price × selected volatility × square root of horizon bars divided by bars per year; selected volatility is annualized standard deviation of log returns, annualized ATR divided by close, or 60% of the former plus 40% of the latter
Calculation: Breakout buffer and retest tolerance = configured ATR multiple, percentage of close, or tick multiple
Calculation: Volatility percentile = percentage of prior lookback values of selected volatility below the current value
Calculation: Volume ratio = current volume / average volume over the volume lookback
Calculation: Quality filter = (volatility filter disabled OR volatility percentile ≥ minimum) AND (volume filter disabled OR volume ratio ≥ minimum)
Calculation: Upper breakout trigger = high ≥ upper barrier in touch mode, close > upper barrier in close mode, or close > upper barrier + breakout buffer in buffered mode
Calculation: Lower breakout trigger = low ≤ lower barrier in touch mode, close < lower barrier in close mode, or close < lower barrier − breakout buffer in buffered mode
Calculation: Active breakout state and barrier = after a quality-passing upper (lower) breakout when the prior direction was not bullish (bearish), set direction to bullish (bearish), record the upper (lower) barrier and breakout bar; clear state after both windows expire if a retest or failure was recorded
Long: upper breakout trigger AND ((NOT quality filter) OR (quality filter AND active breakout direction is not bullish)) OR active bullish breakout AND bars since breakout > 0 AND bars since breakout ≤ retest window AND low ≤ active barrier + retest tolerance AND close ≥ active barrier
Short: lower breakout trigger AND ((NOT quality filter) OR (quality filter AND active breakout direction is not bearish)) OR active bearish breakout AND bars since breakout > 0 AND bars since breakout ≤ retest window AND high ≥ active barrier − retest tolerance AND close ≤ active barrier
Exit: long, active bullish breakout AND bars since breakout > 0 AND bars since breakout ≤ failure window AND close < active barrier
Exit: short, active bearish breakout AND bars since breakout > 0 AND bars since breakout ≤ failure window AND close > active barrier