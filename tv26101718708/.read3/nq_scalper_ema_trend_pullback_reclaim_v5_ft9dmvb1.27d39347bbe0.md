Calculation: Trend EMA = EMA(close, long lookback)
Calculation: Fast EMA = EMA(close, short lookback)
Calculation: RSI = RSI(close, lookback)
Calculation: VWAP = VWAP((high + low + close) / 3)
Calculation: ATR = ATR(high, low, close, lookback)
Long: (session filter disabled OR bar is within the configured session) AND close > Trend EMA AND close[1] < Fast EMA[1] AND close crosses above Fast EMA AND RSI >= long RSI threshold AND (VWAP filter disabled OR close >= VWAP)
Short: (session filter disabled OR bar is within the configured session) AND close < Trend EMA AND close[1] > Fast EMA[1] AND close crosses below Fast EMA AND RSI <= short RSI threshold AND (VWAP filter disabled OR close <= VWAP)
Exit: Long, (trailing stop disabled AND low <= entry price - ATR * stop multiple) OR (trailing stop enabled AND low <= long ATR-based trailing stop using the trailing multiple) OR high >= entry price + ATR * target multiple
Exit: Short, (trailing stop disabled AND high >= entry price + ATR * stop multiple) OR (trailing stop enabled AND high >= short ATR-based trailing stop using the trailing multiple) OR low <= entry price - ATR * target multiple