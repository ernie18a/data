Calculation: MACD line = EMA(close, shorter lookback) − EMA(close, longer lookback)
Calculation: MACD signal = SMA(MACD line, signal lookback)
Calculation: Smoothed Stoch RSI = SMA(stochastic of RSI(close, RSI lookback), smoothing lookback)
Calculation: Stoch RSI signal = SMA(Smoothed Stoch RSI, signal lookback)
Calculation: First higher-timeframe trigger = MACD line >= MACD signal AND Smoothed Stoch RSI >= Stoch RSI signal, using the higher-timeframe bar still forming
Calculation: Second higher-timeframe trigger = MACD line >= MACD signal AND Smoothed Stoch RSI >= Stoch RSI signal, using the higher-timeframe bar still forming
Long: Long trading enabled AND NOT First higher-timeframe trigger AND NOT Second higher-timeframe trigger
Short: Short trading enabled AND First higher-timeframe trigger AND Second higher-timeframe trigger
Exit: short, Long trading disabled AND NOT First higher-timeframe trigger AND NOT Second higher-timeframe trigger
Exit: long, Short trading disabled AND First higher-timeframe trigger AND Second higher-timeframe trigger