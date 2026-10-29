Calculation: Body efficiency = absolute(close − open) divided by candle range.
Calculation: Wick control = a score that decreases as total wick share or the expansion-side wick share increases.
Calculation: Relative volume = volume divided by its moving average over a longer lookback.
Calculation: ATR expansion = candle range divided by average true range.
Calculation: Range expansion = candle range divided by average candle range over a longer lookback.
Calculation: Directional close location = close's location within the candle range, measured from the low for bullish readiness and from the high for bearish readiness.
Calculation: Readiness score = weighted composite of body efficiency, wick control, relative volume, ATR expansion, directional close location, and range expansion.
Calculation: Risk edge = the expansion candle's opposite extreme, offset outward by an ATR-based buffer.
Calculation: Target guide = expansion close plus or minus the greater of a body-size multiple and an ATR-based minimum, in the expansion direction.
Long: bullish readiness side AND readiness score >= ready threshold AND close-location score >= its quality threshold AND body-efficiency score >= its quality threshold AND the selected confirmation gate passes.
Short: bearish readiness side AND readiness score >= ready threshold AND close-location score >= its quality threshold AND body-efficiency score >= its quality threshold AND the selected confirmation gate passes.
Exit: long, active bullish plan AND (close < risk edge OR close >= target guide OR high >= target guide OR follow-through window expired without confirmation or invalidation).
Exit: short, active bearish plan AND (close > risk edge OR close <= target guide OR low <= target guide OR follow-through window expired without confirmation or invalidation).