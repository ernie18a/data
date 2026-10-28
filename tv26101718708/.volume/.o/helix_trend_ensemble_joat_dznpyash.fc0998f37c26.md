Calculation: Each of three trend members = a configurable moving average of close, followed by configurable smoothing; use progressively longer lookbacks for short-, intermediate-, and long-term members.
Calculation: Normalized slope = clamp((member value − its value lookback bars earlier) / max(0.5 × ATR, 0.0001), −1, 1); member direction is its sign and confidence is its absolute value.
Calculation: Consensus = sum of each member’s direction × weight × (0.35 + 0.65 × confidence), divided by total weight.
Calculation: Agreement = count of members with positive direction and count with negative direction; require the relevant count to meet the minimum agreement.
Calculation: Volatility ratio = ATR / its longer-lookback simple moving average.
Calculation: Directional regime = on each confirmed bar, switch to bullish when consensus meets the bullish entry threshold, bullish agreement meets the minimum, ADX meets its threshold, and volatility ratio meets its floor; switch to bearish by the symmetric conditions. Otherwise switch to neutral when absolute consensus is at or below the lower exit threshold and neither directional entry condition holds; otherwise retain the prior regime. The entry threshold is greater than the exit threshold.
Long: Confirmed bar AND bullish entry conditions hold AND prior regime is not bullish.
Short: Confirmed bar AND bearish entry conditions hold AND prior regime is not bearish.
Exit: Long, confirmed bar AND absolute consensus is at or below the exit threshold AND neither bullish nor bearish entry conditions hold.
Exit: Short, confirmed bar AND absolute consensus is at or below the exit threshold AND neither bullish nor bearish entry conditions hold.