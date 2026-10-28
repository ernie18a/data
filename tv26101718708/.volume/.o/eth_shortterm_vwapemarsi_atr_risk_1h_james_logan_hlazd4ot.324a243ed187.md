Long: Position is flat or short AND shorter-term trend EMA > longer-term trend EMA AND current RSI > its threshold AND previous RSI <= its threshold AND close > VWAP AND close >= pullback EMA AND low <= pullback EMA; the pullback EMA has a shorter lookback than both trend EMAs
Short: Position is flat or long AND shorter-term trend EMA < longer-term trend EMA AND current RSI < its threshold AND previous RSI >= its threshold AND close < VWAP AND close <= pullback EMA AND high >= pullback EMA; the pullback EMA has a shorter lookback than both trend EMAs
Exit: Short, Long condition is true
Exit: Long, Short condition is true
Exit: Long, low <= close - ATR × stop multiplier OR high >= close + ATR × take-profit multiplier OR low <= close - ATR × trailing multiplier
Exit: Short, high >= close + ATR × stop multiplier OR low <= close - ATR × take-profit multiplier OR high >= close + ATR × trailing multiplier
Exit: Long or short, bars since entry >= configured maximum holding bars