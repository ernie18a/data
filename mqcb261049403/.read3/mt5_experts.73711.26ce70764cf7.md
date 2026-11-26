Calculation: BoxHigh = highest high of the configured session-box bars on T1, using the last completed bar
Calculation: BoxLow = lowest low of the configured session-box bars on T1, using the last completed bar
Calculation: BoxSize = BoxHigh - BoxLow
Calculation: StopDistance = 0 when stop loss is disabled or the resulting distance is nonpositive; otherwise the fixed stop distance or BoxSize × stop coefficient selected by the stop-loss mode
Calculation: TargetDistance = 0 when take profit is disabled or the resulting distance is nonpositive; otherwise the fixed target distance or BoxSize × target coefficient selected by the take-profit mode
Long: high > BoxHigh
Short: low < BoxLow
Long: box complete AND box-completion weekday enabled AND high >= BoxHigh + entry offset
Short: box complete AND box-completion weekday enabled AND low <= BoxLow - entry offset
Exit: long, StopDistance > 0 AND low <= entry price - StopDistance
Exit: short, StopDistance > 0 AND high >= entry price + StopDistance
Exit: long, TargetDistance > 0 AND high >= entry price + TargetDistance
Exit: short, TargetDistance > 0 AND low <= entry price - TargetDistance
Exit: long, breakeven enabled AND open profit in points >= breakeven trigger AND low <= entry price + locked profit
Exit: short, breakeven enabled AND open profit in points >= breakeven trigger AND high >= entry price - locked profit
Exit: long, trailing enabled AND open profit in points >= trailing distance + trailing start AND low <= the trailing stop set to current price minus trailing distance, raised only when the increase reaches the trailing step
Exit: short, trailing enabled AND open profit in points >= trailing distance + trailing start AND high >= the trailing stop set to current price plus trailing distance, lowered only when the decrease reaches the trailing step
Exit: long, time since entry >= holding-time parameter AND open profit in points >= minimum-profit parameter
Exit: short, time since entry >= holding-time parameter AND open profit in points >= minimum-profit parameter