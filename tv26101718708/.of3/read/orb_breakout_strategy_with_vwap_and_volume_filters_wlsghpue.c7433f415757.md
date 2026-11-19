Calculation: ORB High = maximum high of the first N chart bars of each configured session, fixed after those bars complete
Calculation: ORB Low = minimum low of the first N chart bars of each configured session, fixed after those bars complete
Calculation: Candle position = if high > low then (close - low) / (high - low) else 0.5
Calculation: VWAP slope = session VWAP - session VWAP[n chart bars ago]
Calculation: Long setup = flat AND in configured session AND opening range ready AND trades since session start < trade limit AND close < ORB High AND (VWAP filter disabled OR (close > session VWAP AND VWAP slope > minimum VWAP slope)) AND (volume filter disabled OR volume >= minimum breakout volume) AND (candle filter disabled OR Candle position >= minimum candle strength)
Calculation: Short setup = flat AND in configured session AND opening range ready AND trades since session start < trade limit AND close > ORB Low AND (VWAP filter disabled OR (close < session VWAP AND VWAP slope < -minimum VWAP slope)) AND (volume filter disabled OR volume >= minimum breakout volume) AND (candle filter disabled OR Candle position <= 1 - minimum candle strength)
Long: Long setup OR (Long setup on the prior chart bar AND high >= ORB High on the prior chart bar)
Short: Short setup OR (Short setup on the prior chart bar AND low <= ORB Low on the prior chart bar)
Calculation: Long target = if risk mode is fixed distance then entry price + target distance else entry price + max(entry price - entry bar low, minimum risk distance) × reward ratio
Calculation: Short target = if risk mode is fixed distance then entry price - target distance else entry price - max(entry bar high - entry price, minimum risk distance) × reward ratio
Calculation: Long breakeven reached = breakeven enabled AND highest high since entry >= entry price + (Long target - entry price) × breakeven fraction
Calculation: Short breakeven reached = breakeven enabled AND lowest low since entry <= entry price - (entry price - Short target) × breakeven fraction
Calculation: Long stop = if Long breakeven reached then entry price else if risk mode is fixed distance then entry price - stop distance else entry bar low
Calculation: Short stop = if Short breakeven reached then entry price else if risk mode is fixed distance then entry price + stop distance else entry bar high
Exit: Long, session ends OR high >= Long target OR low <= Long stop
Exit: Short, session ends OR low <= Short target OR high >= Short stop