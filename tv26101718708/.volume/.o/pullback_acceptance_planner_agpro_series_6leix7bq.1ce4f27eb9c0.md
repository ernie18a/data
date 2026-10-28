Calculation: ATR = average true range on the current chart bars
Calculation: Trend EMAs = short-, medium-, and long-lookback EMAs of close, with short < medium < long lookbacks
Calculation: Bull trend = short EMA > medium EMA > long EMA AND medium EMA slope over a lookback, divided by ATR, exceeds a positive threshold; bear trend is the inverse with a negative threshold
Calculation: Acceptance pocket = medium EMA ± an ATR-based width
Calculation: Recent pocket touch = a trend-side bar's range intersects the acceptance pocket within the review window
Calculation: Pullback depth = ATR-normalized distance from the short EMA to the lowest low (bull trend) or highest high (bear trend) in the review window, floored at zero
Calculation: Risk rail = below the lower of the pocket bottom and long EMA for bull trend, or above the higher of the pocket top and long EMA for bear trend, with an ATR-based buffer
Calculation: Target room = ATR-normalized distance from close to the highest high (bull trend) or lowest low (bear trend) over the target lookback, excluding the current bar; if the reference is unavailable or too near/behind price, use the configured clean-room distance
Calculation: Relative volume = current volume / its longer-lookback average
Calculation: Acceptance score = weighted 0–100 sum of normalized pullback-depth quality (rises toward an ideal depth, then falls toward a deep-risk limit), close acceptance, trend slope, volume behavior, risk-distance quality, and target-room quality; use lower relative volume for pullback volume quality before acceptance and higher relative volume for acceptance volume quality
Long: Bull trend AND recent pocket touch AND close > pocket top + ATR-based acceptance buffer AND acceptance score ≥ accepted threshold AND confirmation condition is met AND acceptance was false on the previous bar
Short: Bear trend AND recent pocket touch AND close < pocket bottom − ATR-based acceptance buffer AND acceptance score ≥ accepted threshold AND confirmation condition is met AND acceptance was false on the previous bar
Exit: Long, bull trend AND recent pocket touch AND close < risk rail AND confirmation condition is met AND rejection was false on the previous bar
Exit: Short, bear trend AND recent pocket touch AND close > risk rail AND confirmation condition is met AND rejection was false on the previous bar