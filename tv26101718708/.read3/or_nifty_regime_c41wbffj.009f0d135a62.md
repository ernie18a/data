Calculation: LogRet = LN(close / close[1])
Calculation: NormDisp = (close - EMA(close, EMA length)) / ATR(ATR length)
Calculation: VolRatio = STDEV(LogRet, shorter lookback) / STDEV(LogRet, longer lookback)
Calculation: IVClose = close of implied volatility index on last completed T1 bar
Long: IVClose < no-trade implied volatility threshold AND NormDisp > bullish bias threshold
Short: IVClose < no-trade implied volatility threshold AND NormDisp < bearish bias threshold
Option: sell put, IVClose < no-trade implied volatility threshold AND (NormDisp > bullish bias threshold OR (NormDisp >= bearish bias threshold AND VolRatio <= RV expansion threshold) OR (NormDisp < bearish bias threshold AND VolRatio < RV compression threshold))
Option: sell call, IVClose < no-trade implied volatility threshold AND (NormDisp < bearish bias threshold OR (NormDisp <= bullish bias threshold AND VolRatio <= RV expansion threshold) OR (NormDisp > bullish bias threshold AND VolRatio < RV compression threshold))