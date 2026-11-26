Long: RSI(VWAP(close), momentum lookback) > momentum threshold AND close > EMA(close, trend lookback)
Short: RSI(VWAP(close), momentum lookback) < momentum threshold AND close < EMA(close, trend lookback)
Exit: long, close >= upper Bollinger Band(Bollinger source, Bollinger lookback, inner deviation) AND close <= upper Bollinger Band(Bollinger source, Bollinger lookback, outer deviation)
Exit: short, close <= lower Bollinger Band(Bollinger source, Bollinger lookback, inner deviation) AND close >= lower Bollinger Band(Bollinger source, Bollinger lookback, outer deviation)