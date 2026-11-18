Calculation: Fast SMA = SMA(close, shorter moving-average lookback)
Calculation: RSI = RSI(close, RSI lookback)
Calculation: MACD line and MACD signal line = MACD(close, shorter MACD lookback, longer MACD lookback, signal lookback)
Calculation: ATR = ATR(ATR lookback)
Long: datetime >= midnight on the current date minus the recency lookback days AND Fast SMA > SMA(close, longer moving-average lookback) AND high - low > ATR * volatility ATR multiplier AND RSI < overbought threshold AND RSI > oversold threshold AND MACD line > MACD signal line AND MACD line > 0 AND volume > SMA(volume, volume-average lookback) * volume multiplier AND close > Fast SMA
Short: RSI < oversold threshold
Exit: Long, high >= close * (1 + profit-target percentage / 100) OR low <= max(close * (1 - stop-loss percentage / 100), close - ATR * ATR-stop multiplier) OR high reaches entry price + ATR * trailing-distance multiplier AND low <= highest high since trailing activation - ATR * trailing-distance multiplier