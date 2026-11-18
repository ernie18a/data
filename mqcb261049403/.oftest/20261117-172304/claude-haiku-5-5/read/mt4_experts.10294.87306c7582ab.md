Calculation: barHour = hour of the datetime of the current bar
Calculation: fastMA = EMA over fast period of (high + low) / 2 at the current bar, where fast period is shorter than slow period
Calculation: slowMA = EMA over slow period of (high + low) / 2 at the current bar
Calculation: sar = Parabolic SAR with step parameter and maximum parameter at the current bar
Calculation: bearsPower = low - EMA over power period of close at the current bar
Calculation: prevBearsPower = bearsPower at the previous bar
Calculation: bullsPower = high - EMA over power period of close at the current bar
Calculation: prevBullsPower = bullsPower at the previous bar
Long: barHour > session start hour AND barHour < session end hour AND fastMA > slowMA AND sar < low AND bullsPower > 0 AND bullsPower < prevBullsPower
Short: barHour > session start hour AND barHour < session end hour AND fastMA < slowMA AND sar > high AND bearsPower < 0 AND bearsPower > prevBearsPower
Exit: long, low <= entry price - long stop distance OR high >= entry price + long target distance
Exit: short, high >= entry price + short stop distance OR low <= entry price - short target distance