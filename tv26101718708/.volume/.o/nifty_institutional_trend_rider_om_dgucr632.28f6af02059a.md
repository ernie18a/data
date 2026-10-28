Long: close > VWAP AND close > EMA(close) AND RSI(close) > bullish RSI threshold
Short: close < VWAP AND close < EMA(close) AND RSI(close) < bearish RSI threshold
Calculation: Long trailing stop = while long, max(current close × (1 − trail percentage), prior long trailing stop); reset when flat
Calculation: Short trailing stop = while short, min(current close × (1 + trail percentage), prior short trailing stop); reset when flat
Exit: long, low <= long trailing stop
Exit: short, high >= short trailing stop