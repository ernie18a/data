Calculation: Long stop = low of entry bar minus configured stop buffer
Calculation: Long target = entry-bar close plus configured reward-risk multiple times the distance from entry-bar close to long stop
Calculation: Short stop = high of entry bar plus configured stop buffer
Calculation: Short target = entry-bar close minus configured reward-risk multiple times the distance from short stop to entry-bar close
Long: datetime is at or after configured start time AND bars since most recent entry are at least the configured cooldown AND position is flat AND low > long-term EMA AND close > VWAP AND ADX > configured threshold AND ADX > its shorter-lookback simple moving average AND current short-lookback RSI > current longer-lookback RSI AND previous short-lookback RSI <= previous longer-lookback RSI
Short: datetime is at or after configured start time AND bars since most recent entry are at least the configured cooldown AND position is flat AND high < long-term EMA AND close < VWAP AND ADX > configured threshold AND ADX > its shorter-lookback simple moving average AND current short-lookback RSI < current longer-lookback RSI AND previous short-lookback RSI >= previous longer-lookback RSI
Exit: long, low <= long stop OR high >= long target
Exit: short, high >= short stop OR low <= short target