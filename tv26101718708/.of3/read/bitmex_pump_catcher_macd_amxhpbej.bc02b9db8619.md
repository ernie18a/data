Calculation: Relative volume = SUM(volume, volume block length) / AVERAGE(SUM(volume, volume block length)[k × volume block length] for k = 1 through volume history block count)
Calculation: MACD change = MACD(close, MACD shorter lookback, MACD longer lookback) - MACD(close, MACD shorter lookback, MACD longer lookback)[1]
Long: Relative volume crosses above volume threshold AND rising(EMA(Relative volume, volume EMA longer lookback), rising lookback) AND MACD change > 0
Short: Relative volume crosses above volume threshold AND rising(EMA(Relative volume, volume EMA longer lookback), rising lookback) AND MACD change < 0
Exit: Long, EMA(Relative volume, volume EMA longer lookback) > EMA(Relative volume, volume EMA shorter lookback)
Exit: Short, EMA(Relative volume, volume EMA longer lookback) > EMA(Relative volume, volume EMA shorter lookback)
Exit: Long, low <= average entry price × (1 - stop-loss percent / (100 × leverage))
Exit: Short, high >= average entry price × (1 + stop-loss percent / (100 × leverage))