Long: close > VWAP(close) AND close > EMA(close, EMA lookback) AND RSI(close, RSI lookback) > bullish RSI threshold
Short: close < VWAP(close) AND close < EMA(close, EMA lookback) AND RSI(close, RSI lookback) < bearish RSI threshold
Calculation: Long trailing stop = max(close * (1 - trailing percentage), long trailing stop[1]) while long; reset while flat
Calculation: Short trailing stop = close * (1 + trailing percentage) on the first short bar; thereafter min(close * (1 + trailing percentage), short trailing stop[1])
Exit: Long, low <= long trailing stop
Exit: Short, high >= short trailing stop