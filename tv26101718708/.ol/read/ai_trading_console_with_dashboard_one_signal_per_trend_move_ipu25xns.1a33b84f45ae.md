Calculation: Opening range high = highest high from bars timestamped 09:00–09:29 on the current day, reset each day
Calculation: Opening range low = lowest low from bars timestamped 09:00–09:29 on the current day, reset each day
Calculation: Long stop = at entry, entry price − entry-bar ATR × initial-stop multiplier; while long and trailing is enabled, update to the maximum of the prior long stop and current close − current ATR × trailing multiplier
Calculation: Short stop = at entry, entry price + entry-bar ATR × initial-stop multiplier; while short and trailing is enabled, update to the minimum of the prior short stop and current close + current ATR × trailing multiplier
Long: flat AND last entry signal was not long AND close crosses above opening range high AND fast EMA > slow EMA AND RSI > buy threshold AND ADX > minimum threshold AND higher-timeframe close > its 50-period EMA (use the still-forming higher-timeframe bar)
Short: flat AND last entry signal was not short AND close crosses below opening range low AND fast EMA < slow EMA AND RSI < sell threshold AND ADX > minimum threshold AND higher-timeframe close < its 50-period EMA (use the still-forming higher-timeframe bar)
Exit: long, close < long stop
Exit: short, close > short stop