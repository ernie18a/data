Calculation: Momentum = average of RSI(close, lookback) and MFI(hlc3, same lookback), where RSI uses Wilder averages of positive and negative close-to-close changes
Calculation: Trend average = selected moving average of higher-timeframe close × chart-bar volume divided by selected moving average of chart-bar volume, using the same lookback as higher-timeframe ATR
Long: Momentum crossed above the positive threshold, Momentum > the negative threshold, EMA(close, short lookback) is rising, and the prior bar was not in positive momentum state
Short: Momentum < the negative threshold, EMA(close, short lookback) is falling, and the prior bar was not in negative momentum state
Exit: Long, short-entry condition OR low <= trend average + (factor × higher-timeframe ATR) − (factor × higher-timeframe ATR)
Exit: Short, long-entry condition OR high >= trend average + (factor × higher-timeframe ATR) + (factor × higher-timeframe ATR)