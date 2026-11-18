Calculation: upper gap boundary = max(close[1], open), set at the start of each day
Calculation: lower gap boundary = min(close[1], open), set at the start of each day
Calculation: tradeEligible = no entry has occurred today AND position is flat AND both gap boundaries are defined AND the current bar is within an enabled session in New York time
Calculation: tracked swing point = while tradeEligible and high >= lower gap boundary and low <= upper gap boundary, initialize to low if close > upper gap boundary, otherwise high; thereafter use min(previous tracked swing point, low) if close > upper gap boundary, otherwise max(previous tracked swing point, high); retain its value on other bars and clear it after entry
Long: tradeEligible AND tracked swing point is defined AND close > upper gap boundary AND low[1] <= upper gap boundary
Short: tradeEligible AND tracked swing point is defined AND close < lower gap boundary AND high[1] >= lower gap boundary
Exit: Long, low <= tracked swing point captured at entry minus the stop offset in ticks
Exit: Short, high >= tracked swing point captured at entry plus the stop offset in ticks