Calculation: Bull trend score = count of: close > long-term EMA; medium-term EMA > long-term EMA; short-term EMA > medium-term EMA; +DI > -DI. EMA periods are ordered short to long.
Calculation: Bear trend score = count of: close < long-term EMA; medium-term EMA < long-term EMA; short-term EMA < medium-term EMA; -DI > +DI. EMA periods are ordered short to long.
Long: Bull trend score >= trend threshold
Short: Bear trend score >= trend threshold
Long: Bull trend score >= trend threshold AND ADX > quality threshold AND 35 < RSI < 65 AND higher-timeframe close > higher-timeframe medium-term EMA AND higher-timeframe close > higher-timeframe long-term EMA AND bars since prior quality buy > quality cooldown. Higher-timeframe values use the request.security lookahead_off behavior: the bar still forming in realtime and the last completed bar in historical data.
Short: Bear trend score >= trend threshold AND ADX > quality threshold AND 35 < RSI < 65 AND higher-timeframe close < higher-timeframe medium-term EMA AND higher-timeframe close < higher-timeframe long-term EMA AND bars since prior quality sell > quality cooldown. Higher-timeframe values use the request.security lookahead_off behavior: the bar still forming in realtime and the last completed bar in historical data.
Long: A confirmed swing low is lower than the prior confirmed swing low AND its RSI pivot is higher than the prior RSI pivot low AND bars since prior bullish divergence > divergence cooldown
Short: A confirmed swing high is higher than the prior confirmed swing high AND its RSI pivot is lower than the prior RSI pivot high AND bars since prior bearish divergence > divergence cooldown
Long: Close crosses above the latest confirmed swing high (prior close <= that level AND current close > that level)
Short: Close crosses below the latest confirmed swing low (prior close >= that level AND current close < that level)
Long: A confirmed swing high is higher than the prior confirmed swing high OR a confirmed swing low is higher than the prior confirmed swing low
Short: A confirmed swing high is lower than the prior confirmed swing high OR a confirmed swing low is lower than the prior confirmed swing low