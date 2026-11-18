Long: RSI(close, R) > P_long_trend AND close > EMA(low, E) AND entry price > high
Long: RSI(close, R) > P_mid AND close < EMA(VWAP, M) AND close > EMA(low, E) AND entry price > high
Short: RSI(close, R) < P_short_trend AND close < EMA(low, E) AND entry price < low
Short: RSI(close, R) < P_mid AND close > EMA(VWAP, M) AND close < EMA(low, E) AND entry price < low
Exit: long, RSI(close, R) < P_mid AND close < EMA(low, E)
Exit: short, RSI(close, R) > P_mid AND close > EMA(low, E)
Exit: long, RSI(close, R) > P_long_profit AND close > EMA(low, E)
Exit: short, RSI(close, R) < P_short_profit AND close < EMA(low, E)