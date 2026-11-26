Long: EMA(close, shorter lookback) > EMA(close, longer lookback) AND low[1] <= EMA(close, shorter lookback)[1] AND close > EMA(close, shorter lookback) AND volume > SMA(volume, volume lookback) AND RSI(close, long RSI lookback) > long RSI threshold AND flat AND bar is confirmed
Short: EMA(close, shorter lookback) < EMA(close, longer lookback) AND high[1] >= EMA(close, shorter lookback)[1] AND close < EMA(close, shorter lookback) AND volume > SMA(volume, volume lookback) AND RSI(close, short RSI lookback) < short RSI threshold AND flat AND bar is confirmed
Calculation: long stop = lowest(low, swing lookback) - ATR(ATR lookback) * stop buffer, fixed at the long entry signal bar
Calculation: long target = close + ATR(ATR lookback) * target multiple, fixed at the long entry signal bar
Exit: long, low <= long stop OR high >= long target
Calculation: short stop = highest(high, swing lookback) + ATR(ATR lookback) * stop buffer, fixed at the short entry signal bar
Calculation: short target = close - ATR(ATR lookback) * target multiple, fixed at the short entry signal bar
Exit: short, high >= short stop OR low <= short target