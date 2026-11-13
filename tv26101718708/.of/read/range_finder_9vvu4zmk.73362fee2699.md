Calculation: range high = most recent confirmed swing-high pivot of high (a bar whose high is the highest among an equal number of bars on its left and right; confirmed only after the right-side bars complete)
Calculation: range low = most recent confirmed swing-low pivot of low (a bar whose low is the lowest among an equal number of bars on its left and right; confirmed only after the right-side bars complete)
Calculation: long EMA = EMA of close with longer lookback, computed on a separately chosen timeframe (may differ from chart timeframe), value of the bar still forming at the current chart bar
Calculation: short EMA = EMA of close with shorter lookback than long EMA, same timeframe and bar convention as long EMA
Calculation: trend state = UP from the bar where short EMA crosses above long EMA until short EMA crosses below long EMA; DOWN from the bar where short EMA crosses below long EMA until it crosses above again; no state before the first cross
Calculation: body = abs(close - open); upper wick = high - max(open, close); lower wick = min(open, close) - low; wick ratio = a fixed threshold >= 1
Calculation: ATR = Average True Range at the signal bar
Short: range high exists AND high > range high AND close < open AND upper wick >= body * wick ratio AND trend state = DOWN AND close < long EMA (signal bar = the bar where all hold)
Long: range low exists AND low < range low AND close > open AND lower wick >= body * wick ratio AND trend state = UP AND close > long EMA (signal bar = the bar where all hold)
Exit: short, high >= signal-bar high + ATR * stop multiplier (stop) OR low <= signal-bar close - ATR * target multiplier * reward:risk ratio (take profit)
Exit: long, low <= signal-bar low - ATR * stop multiplier (stop) OR high >= signal-bar close + ATR * target multiplier * reward:risk ratio (take profit)