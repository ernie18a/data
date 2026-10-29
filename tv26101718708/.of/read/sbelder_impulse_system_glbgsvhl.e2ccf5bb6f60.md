Calculation: MACD histogram = (short-lookback EMA(close) − long-lookback EMA(close)) − simple moving average of that EMA difference over the signal lookback
Long: EMA(close) > previous-bar EMA(close) AND MACD histogram > previous-bar MACD histogram
Short: EMA(close) < previous-bar EMA(close) AND MACD histogram < previous-bar MACD histogram
Exit: long or short, (EMA(close) >= previous-bar EMA(close) AND MACD histogram <= previous-bar MACD histogram) OR (EMA(close) <= previous-bar EMA(close) AND MACD histogram >= previous-bar MACD histogram)