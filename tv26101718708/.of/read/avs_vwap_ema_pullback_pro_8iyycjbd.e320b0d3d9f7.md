Long: within the configured trading session AND ADX >= minimum threshold AND close > VWAP AND fast EMA > slow EMA AND +DI > -DI AND low <= VWAP * (1 + pullback threshold) AND close > VWAP AND close > fast EMA AND RSI > long threshold AND short condition is false AND position is flat or short AND long risk > 0
Short: within the configured trading session AND ADX >= minimum threshold AND close < VWAP AND fast EMA < slow EMA AND -DI > +DI AND high >= VWAP * (1 - pullback threshold) AND close < VWAP AND close < fast EMA AND RSI < short threshold AND long condition is false AND position is flat or long AND short risk > 0
Calculation: Long stop = min(VWAP, slow EMA) - ATR * stop multiplier
Calculation: Long risk = entry price - long stop
Calculation: Long target 1 = entry price + long risk * first reward-to-risk multiple
Calculation: Long target 2 = entry price + long risk * second reward-to-risk multiple
Calculation: Short stop = max(VWAP, slow EMA) + ATR * stop multiplier
Calculation: Short risk = short stop - entry price
Calculation: Short target 1 = entry price - short risk * first reward-to-risk multiple
Calculation: Short target 2 = entry price - short risk * second reward-to-risk multiple
Exit: Long, low <= long stop OR high >= long target 1
Exit: Long, low <= long stop OR high >= long target 2
Exit: Short, high >= short stop OR low <= short target 1
Exit: Short, high >= short stop OR low <= short target 2